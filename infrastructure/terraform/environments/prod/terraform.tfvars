# Project ID (bạn đã cung cấp). Nếu repo public, cân nhắc chỉ set qua TF_VAR_project_id / env.
project_id = "videocall-493506"

region = "asia-southeast1"
domain = "jbcalling.site"

# Ubuntu 22.04 trên GCE: user SSH mặc định thường là "ubuntu" (khớp với inventory Ansible)
ssh_user = "ubuntu"

ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILmNi5TJhQQZPlI40FCVVX6DwPWMvpJdMuGd6GuPit0S jbcalling-gce"

service_account_email = "vm-default@videocall-493506.iam.gserviceaccount.com"

# Leave empty to use Application Default Credentials (gcloud auth application-default login)
credentials_file = ""

network_name = "translation-vpc"
subnet_cidr  = "10.148.0.0/20"

velero_bucket_name     = "jbcalling-velero-backups"
velero_bucket_location = "ASIA-SOUTHEAST1"

# Project mới: static_ip để "" — sau terraform output lấy IP thật cập nhật vào Ansible inventory.
instances = {
  translation01 = {
    machine_type = "c4d-standard-4"
    zone         = "asia-southeast1-a"
    static_ip    = ""
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
    static_ip    = ""
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
