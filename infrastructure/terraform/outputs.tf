output "network_name" {
  description = "VPC network name"
  value       = module.network.network_name
}

output "network_id" {
  description = "VPC network self-link"
  value       = module.network.network_id
}

output "subnet_id" {
  description = "Subnet self-link"
  value       = module.network.subnet_id
}

output "instance_external_ips" {
  description = "Map of instance name to external IP"
  value       = module.compute.instance_external_ips
}

output "instance_internal_ips" {
  description = "Map of instance name to internal IP"
  value       = module.compute.instance_internal_ips
}

output "instance_self_links" {
  description = "Map of instance name to self-link"
  value       = module.compute.instance_self_links
}

output "dns_zone_name" {
  description = "Cloud DNS managed zone name"
  value       = module.dns.zone_name
}

output "dns_name_servers" {
  description = "Cloud DNS name servers for the zone"
  value       = module.dns.name_servers
}

output "velero_bucket_name" {
  description = "GCS bucket name for Velero backups"
  value       = google_storage_bucket.velero_backups.name
}

output "velero_bucket_url" {
  description = "GCS bucket URL for Velero backups"
  value       = google_storage_bucket.velero_backups.url
}

output "firewall_rule_names" {
  description = "Names of created firewall rules"
  value       = module.firewall.firewall_rule_names
}
