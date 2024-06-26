# Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
}

# Create subnets
resource "google_compute_subnetwork" "subnet" {
  count                    = length(var.deployment_regions)
  name                     = format("subnet-%s-%d", var.deployment_regions[count.index], count.index + 1)
  ip_cidr_range            = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  network                  = google_compute_network.vpc_network.self_link
  region                   = var.deployment_regions[count.index]
  private_ip_google_access = true
}

# Create a Cloud Router in each region
resource "google_compute_router" "router" {
  count   = length(var.deployment_regions)
  name    = format("%s-router-%d", var.project_name, count.index + 1)
  network = google_compute_network.vpc_network.self_link
  region  = var.deployment_regions[count.index]
}

# Create Cloud NAT in each region
resource "google_compute_router_nat" "cloud_nat" {
  count                              = length(var.deployment_regions)
  name                               = format("cloud-nat-%d", count.index + 1)
  router                             = element(google_compute_router.router.*.name, count.index)
  region                             = element(var.deployment_regions, count.index)
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = element(google_compute_subnetwork.subnet.*.self_link, count.index)
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# Peering from this network to Service Project's VPC
resource "google_compute_network_peering" "peer_to_services" {
  count        = var.services_vpc_self_link != "" ? 1 : 0
  name         = "peering-to-services"
  network      = google_compute_network.vpc_network.self_link
  peer_network = var.services_vpc_self_link
}