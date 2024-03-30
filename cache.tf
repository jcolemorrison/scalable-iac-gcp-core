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

  # Use a /29 block within the 10.0.255.0/24 space, max of 32 instances
  # reserved_ip_range  = format("10.0.255.%d/29", count.index * 8)

  # Use a /29 block within the 10.0.254.0/23 space, max of 64 instances
  reserved_ip_range  = format("10.0.%d.%d/29", 254 + floor(count.index / 32), (count.index % 32) * 8)  
}

resource "google_project_iam_member" "redis_reader" {
  count   = length(var.redis_service_accounts) == 0 ? 0 : length(var.redis_service_accounts)
  project = var.gcp_project_id
  role    = "roles/redis.viewer"
  member  = "serviceAccount:${var.redis_service_accounts[count.index]}"
}

# Create a firewall rule that allows internal VPC traffic on port 6379
resource "google_compute_firewall" "redis_firewall" {
  name    = "redis-firewall"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }

  source_ranges = [var.vpc_cidr_block] # TBD: restrict to VPC and all peers
}