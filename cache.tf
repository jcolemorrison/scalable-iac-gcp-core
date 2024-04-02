# Create a Redis instance in each region
resource "google_redis_instance" "cache" {
  count              = length(var.deployment_regions)
  name               = format("redis-%s-%d", var.deployment_regions[count.index], count.index + 1)
  memory_size_gb     = 5
  region             = var.deployment_regions[count.index]
  authorized_network = google_compute_network.vpc_network.self_link
  redis_version      = "REDIS_7_2"
  display_name       = format("Redis Instance %s %d", var.deployment_regions[count.index], count.index + 1)
  tier               = "STANDARD_HA"  # Use the Standard HA Tier
  replica_count      = 1
  read_replicas_mode = "READ_REPLICAS_ENABLED"

  # For Direct Access - Use a /28 block within the 10.0.255.0/24 space, max of 16 instances
  reserved_ip_range  = format("10.0.255.%d/28", (count.index % 16) * 16)
}

resource "google_project_iam_member" "redis_reader" {
  count   = length(var.redis_service_accounts) == 0 ? 0 : length(var.redis_service_accounts)
  project = var.gcp_project_id
  role    = "roles/redis.viewer"
  member  = "serviceAccount:${var.redis_service_accounts[count.index]}"
}

resource "google_project_iam_member" "redis_admin" {
  project = var.gcp_project_id
  role    = "roles/redis.admin"
  member  = "serviceAccount:${google_service_account.server.email}"
}

# Create a firewall rule that allows internal VPC traffic on port 6379
resource "google_compute_firewall" "redis_firewall" {
  name    = "redis-firewall"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }

  source_ranges = [var.vpc_cidr_block]
}

# Create a service account for proxy instances
resource "google_service_account" "redis_proxy" {
  account_id   = "redis-proxy"
  display_name = "Redis Proxy Service Account"
}

resource "google_project_iam_member" "redis_proxy_reader" {
  project = var.gcp_project_id
  role    = "roles/redis.viewer"
  member  = "serviceAccount:${google_service_account.redis_proxy.email}"
}

# Create Proxy servers for Redis in each region
resource "google_compute_instance_template" "redis_proxy" {
  count        = length(var.deployment_regions)
  name_prefix  = "proxy-${var.deployment_regions[count.index]}"
  machine_type = var.proxy_instance_type

  disk {
    source_image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = element(google_compute_subnetwork.subnet.*.self_link, count.index)

    access_config {
    }
  }

  metadata = {
    project_name = var.project_name
  }

  metadata_startup_script = templatefile("${path.module}/scripts/proxy.sh", {
    REDIS_HOST  = google_redis_instance.cache[count.index].read_endpoint
  })

  service_account {
    email = google_service_account.redis_proxy.email
    scopes = ["cloud-platform"]
  }

  tags = ["proxy"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_from_template" "redis_proxy" {
  count = length(var.deployment_regions)
  name  = format("proxy-%s", var.deployment_regions[count.index])
  zone  = element(data.google_compute_zones.available[count.index].names, 0)
  source_instance_template = google_compute_instance_template.redis_proxy[count.index].self_link
}

resource "google_compute_firewall" "redis_proxy_firewall" {
  name    = "redis-proxy-firewall"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }

  source_ranges = var.allowed_proxy_cidr_blocks
  target_tags   = ["proxy"]
}