output "vpc_self_link" {
  description = "The self-link of the VPC network"
  value       = google_compute_network.vpc_network.self_link
}

output "server_loadbalancer_ip" {
  description = "The IP address of the global load balancer"
  value       = google_compute_global_address.server.address
}

output "redis_read_endpoints" {
  description = "Map of regions to game server Redis instance read endpoints"
  value = zipmap(
    var.deployment_regions,
    google_redis_instance.cache.*.read_endpoint[0].ip_address
  )
}

output "redis_host_endpoints" {
  description = "Map of regions to game server Redis instance host endpoints"
  value = zipmap(
    var.deployment_regions,
    google_redis_instance.cache.*.host
  )
}