module "network" {
  source = "./modules/network"

  project_id   = var.project_id
  region       = var.region
  network_name = var.network_name
  subnet_cidr  = var.subnet_cidr
}

module "firewall" {
  source = "./modules/firewall"

  project_id   = var.project_id
  network_name = module.network.network_name
  network_id   = module.network.network_id
  subnet_cidr  = var.subnet_cidr
}

module "compute" {
  source = "./modules/compute"

  project_id            = var.project_id
  instances             = var.instances
  network_id            = module.network.network_id
  subnet_id             = module.network.subnet_id
  ssh_user              = var.ssh_user
  ssh_public_key        = var.ssh_public_key
  service_account_email = var.service_account_email
}

module "dns" {
  source = "./modules/dns"

  project_id  = var.project_id
  domain      = var.domain
  instance_ips = module.compute.instance_external_ips
}

resource "google_storage_bucket" "velero_backups" {
  name          = var.velero_bucket_name
  location      = var.velero_bucket_location
  project       = var.project_id
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    purpose = "velero-backups"
    env     = "prod"
  }
}
