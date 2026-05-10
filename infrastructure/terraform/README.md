# Translation System - Terraform Infrastructure

Terraform IaC for provisioning GCE instances, VPC networking, firewall rules, Cloud DNS, and GCS buckets on Google Cloud Platform for the Kubernetes (kubeadm) cluster.

## Architecture

| Instance | Machine Type | Zone | External IP | Role |
|---|---|---|---|---|
| translation01 | c4d-standard-4 | asia-southeast1-a | 35.198.221.169 | Manager + AI |
| translation02 | c2d-standard-4 | asia-southeast1-b | 34.126.152.20 | Worker + WebRTC |
| translation03 | c2d-highcpu-4 | asia-southeast1-b | 34.158.47.145 | Worker + Monitoring |

## Modules

- **network** - VPC, subnet, Cloud NAT, Cloud Router
- **firewall** - SSH, HTTP/S, WebRTC, TURN/STUN, K8s API, internal cluster communication
- **compute** - 3 GCE instances with static IPs, shielded VM, service accounts
- **dns** - Cloud DNS managed zone with apex and wildcard A records

## Prerequisites

1. [Terraform >= 1.5](https://developer.hashicorp.com/terraform/install)
2. [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
3. A GCP project with Compute Engine, Cloud DNS, and Cloud Storage APIs enabled
4. A GCS bucket for Terraform state (`jbcalling-tf-state`)
5. A service account with appropriate IAM roles

## Setup

### 1. Authenticate

```bash
gcloud auth application-default login
```

Or set a service account key:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"
```

### 2. Configure Variables

Edit `environments/prod/terraform.tfvars` and uncomment/fill in the required values:

- `project_id` - your GCP project ID
- `ssh_public_key` - your SSH public key content
- `service_account_email` - service account email for instances

### 3. Create State Bucket

```bash
gsutil mb -p YOUR_PROJECT_ID -l asia-southeast1 gs://jbcalling-tf-state
gsutil versioning set on gs://jbcalling-tf-state
```

### 4. Initialize and Apply

```bash
cd infrastructure/terraform

terraform init

terraform plan -var-file=environments/prod/terraform.tfvars

terraform apply -var-file=environments/prod/terraform.tfvars
```

### 5. Import Existing Resources (if migrating)

If instances already exist, import them before applying:

```bash
terraform import -var-file=environments/prod/terraform.tfvars \
  'module.compute.google_compute_instance.node["translation01"]' \
  projects/YOUR_PROJECT/zones/asia-southeast1-a/instances/translation01

terraform import -var-file=environments/prod/terraform.tfvars \
  'module.compute.google_compute_instance.node["translation02"]' \
  projects/YOUR_PROJECT/zones/asia-southeast1-b/instances/translation02

terraform import -var-file=environments/prod/terraform.tfvars \
  'module.compute.google_compute_instance.node["translation03"]' \
  projects/YOUR_PROJECT/zones/asia-southeast1-b/instances/translation03
```

## Outputs

| Output | Description |
|---|---|
| `instance_external_ips` | Map of instance name to external IP |
| `instance_internal_ips` | Map of instance name to internal IP |
| `dns_name_servers` | Cloud DNS name servers (update at domain registrar) |
| `velero_bucket_name` | GCS bucket for Velero backups |
| `firewall_rule_names` | List of created firewall rules |

## Firewall Rules

| Rule | Protocol/Ports | Source | Purpose |
|---|---|---|---|
| allow-ssh | TCP 22 | 0.0.0.0/0 | SSH access |
| allow-http-https | TCP 80, 443 | 0.0.0.0/0 | Web traffic |
| allow-webrtc-udp | UDP 40000-40019 | 0.0.0.0/0 | WebRTC media |
| allow-turn | TCP/UDP 3478, 5349; UDP 49152-49156 | 0.0.0.0/0 | TURN/STUN |
| allow-k8s-api | TCP 6443 | 0.0.0.0/0 | Kubernetes API |
| allow-internal-cluster | TCP 2379-2380, 10250, 10257, 10259, 30000-32767; UDP 4789 | VPC CIDR | Internal K8s |
| allow-internal-icmp | ICMP | VPC CIDR | Node health checks |
