output "zone_name" {
  description = "Cloud DNS managed zone name"
  value       = google_dns_managed_zone.primary.name
}

output "zone_dns_name" {
  description = "Cloud DNS managed zone DNS name"
  value       = google_dns_managed_zone.primary.dns_name
}

output "name_servers" {
  description = "Cloud DNS name servers"
  value       = google_dns_managed_zone.primary.name_servers
}
