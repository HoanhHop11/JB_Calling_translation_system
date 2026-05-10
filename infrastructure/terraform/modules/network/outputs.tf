output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.vpc.name
}

output "network_id" {
  description = "VPC network self-link"
  value       = google_compute_network.vpc.self_link
}

output "subnet_id" {
  description = "Subnet self-link"
  value       = google_compute_subnetwork.primary.self_link
}

output "subnet_name" {
  description = "Subnet name"
  value       = google_compute_subnetwork.primary.name
}
