variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "domain" {
  description = "Primary domain name (e.g. jbcalling.site)"
  type        = string
}

variable "instance_ips" {
  description = "Map of instance name to external IP for DNS records"
  type        = map(string)
}
