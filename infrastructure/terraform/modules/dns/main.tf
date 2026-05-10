locals {
  all_ips = values(var.instance_ips)
}

resource "google_dns_managed_zone" "primary" {
  name        = replace(var.domain, ".", "-")
  project     = var.project_id
  dns_name    = "${var.domain}."
  description = "DNS zone for ${var.domain}"

  visibility = "public"

  dnssec_config {
    state = "on"
  }
}

resource "google_dns_record_set" "apex" {
  name         = "${var.domain}."
  project      = var.project_id
  managed_zone = google_dns_managed_zone.primary.name
  type         = "A"
  ttl          = 300
  rrdatas      = local.all_ips
}

resource "google_dns_record_set" "wildcard" {
  name         = "*.${var.domain}."
  project      = var.project_id
  managed_zone = google_dns_managed_zone.primary.name
  type         = "A"
  ttl          = 300
  rrdatas      = local.all_ips
}
