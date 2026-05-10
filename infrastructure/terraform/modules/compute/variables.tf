variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "instances" {
  description = "Map of GCE instance configurations"
  type = map(object({
    machine_type = string
    zone         = string
    static_ip    = string
    internal_ip  = string
    boot_disk = object({
      image = string
      size  = number
      type  = string
    })
    labels = map(string)
    role   = string
  }))
}

variable "network_id" {
  description = "VPC network self-link"
  type        = string
}

variable "subnet_id" {
  description = "Subnet self-link"
  type        = string
}

variable "ssh_user" {
  description = "SSH username"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
}

variable "service_account_email" {
  description = "Service account email to attach to instances"
  type        = string
}
