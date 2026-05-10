resource "google_compute_address" "static_ip" {
  for_each = var.instances

  name         = "${each.key}-ip"
  project      = var.project_id
  region       = regex("^(.*)-[a-z]$", each.value.zone)[0]
  # Để trống static_ip trong tfvars = GCP tự cấp IP (bắt buộc cho project mới).
  # Chỉ điền khi bạn đã có external IP reserve sẵn trong project.
  address      = trimspace(each.value.static_ip) != "" ? each.value.static_ip : null
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "node" {
  for_each = var.instances

  name         = each.key
  project      = var.project_id
  machine_type = each.value.machine_type
  zone         = each.value.zone

  tags = ["translation-node", each.value.role]

  labels = each.value.labels

  boot_disk {
    initialize_params {
      image = each.value.boot_disk.image
      size  = each.value.boot_disk.size
      type  = each.value.boot_disk.type
    }
  }

  network_interface {
    subnetwork = var.subnet_id
    network_ip = each.value.internal_ip

    access_config {
      nat_ip = google_compute_address.static_ip[each.key].address
    }
  }

  metadata = {
    ssh-keys                = "${var.ssh_user}:${var.ssh_public_key}"
    enable-oslogin          = "FALSE"
    block-project-ssh-keys  = "TRUE"
  }

  service_account {
    email  = var.service_account_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  allow_stopping_for_update = true

  lifecycle {
    prevent_destroy = true
  }
}
