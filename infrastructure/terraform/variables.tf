variable "project_id" {
  description = "GCP project ID"
  type        = string
  # REQUIRED: provide your value
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "asia-southeast1"
}

variable "credentials_file" {
  description = "Path to GCP service account JSON key file (leave empty to use ADC)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "domain" {
  description = "Primary domain name"
  type        = string
  default     = "jbcalling.site"
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  # REQUIRED: provide your value
}

variable "ssh_user" {
  description = "SSH username for instance access"
  type        = string
  default     = "admin"
}

variable "service_account_email" {
  description = "Service account email to attach to instances"
  type        = string
  # REQUIRED: provide your value
}

variable "velero_bucket_name" {
  description = "GCS bucket name for Velero backups"
  type        = string
  default     = "jbcalling-velero-backups"
}

variable "velero_bucket_location" {
  description = "Location for the Velero backup bucket"
  type        = string
  default     = "ASIA-SOUTHEAST1"
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
  default = {
    translation01 = {
      machine_type = "c4d-standard-4"
      zone         = "asia-southeast1-a"
      static_ip    = "" # project mới: để trống để GCP cấp IP
      internal_ip  = "10.148.0.5"
      boot_disk = {
        image = "ubuntu-os-cloud/ubuntu-2204-lts"
        size  = 50
        type  = "pd-ssd"
      }
      labels = {
        instance = "translation01"
        role     = "manager-ai"
        env      = "prod"
      }
      role = "manager"
    }
    translation02 = {
      machine_type = "c2d-standard-4"
      zone         = "asia-southeast1-b"
      static_ip    = "34.126.152.20"
      internal_ip  = "10.148.0.3"
      boot_disk = {
        image = "ubuntu-os-cloud/ubuntu-2204-lts"
        size  = 50
        type  = "pd-ssd"
      }
      labels = {
        instance = "translation02"
        role     = "worker-webrtc"
        env      = "prod"
      }
      role = "worker"
    }
    translation03 = {
      machine_type = "c2d-highcpu-4"
      zone         = "asia-southeast1-b"
      static_ip    = ""
      internal_ip  = "10.148.0.4"
      boot_disk = {
        image = "ubuntu-os-cloud/ubuntu-2204-lts"
        size  = 50
        type  = "pd-ssd"
      }
      labels = {
        instance = "translation03"
        role     = "worker-monitoring"
        env      = "prod"
      }
      role = "worker"
    }
  }
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "translation-vpc"
}

variable "subnet_cidr" {
  description = "CIDR range for the primary subnet"
  type        = string
  default     = "10.148.0.0/20"
}
