output "vpc_self_link" {
  description = "The self-link of the VPC network"
  value       = google_compute_network.vpc_network.self_link
}

output "server_loadbalancer_ip" {
  description = "The IP address of the global load balancer. Used as SERVER_HOST in client."
  value       = google_compute_global_address.server.address
}

output "redis_read_endpoints" {
  description = "Map of regions to game server Redis instance read endpoints"
  value = zipmap(
    var.deployment_regions,
    [for instance in google_redis_instance.cache : instance.read_endpoint]
  )
}

output "redis_host_endpoints" {
  description = "Map of regions to game server Redis instance host endpoints"
  value = zipmap(
    var.deployment_regions,
    google_redis_instance.cache.*.host
  )
}

output "client_url_map_name" {
  description = "The name of the client URL map"
  value       = google_compute_url_map.client.name
}

output "client_site_bucket_name" {
  description = "The name of the client site bucket"
  value       = google_storage_bucket.client_site_bucket.name
}

output "server_service_account_email" {
  description = "The email of the server service account"
  value       = google_service_account.server.email
}