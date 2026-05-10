variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "network_id" {
  description = "VPC network self-link"
  type        = string
}

variable "subnet_cidr" {
  description = "Internal subnet CIDR for cluster communication rules"
  type        = string
}
