# Infrastructure as Code - Terraform & Ansible

**Version**: 1.0
**Last Updated**: 2026-05-05

## Tổng quan

- **Terraform**: Quản lý hạ tầng GCP (VPC, firewall, GCE instances, Cloud DNS, GCS buckets)
- **Ansible**: Bootstrap K8s cluster (kubeadm init/join, containerd, Calico CNI)

## Terraform

### Cấu trúc

```
infrastructure/terraform/
├── main.tf                    # Root module, gọi submodules
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── versions.tf                # Provider + Terraform version constraints
├── backend.tf                 # GCS backend cho state
├── .gitignore                 # Ignore .terraform, *.tfstate, etc.
├── modules/
│   ├── network/               # VPC + subnet
│   ├── firewall/              # Firewall rules
│   ├── compute/               # GCE instances + static IPs
│   └── dns/                   # Cloud DNS zone + records
└── environments/
    └── prod/
        └── terraform.tfvars   # Production values
```

### Sử dụng

```bash
cd infrastructure/terraform

# 1. Khởi tạo (lần đầu)
terraform init

# 2. Xem plan
terraform plan -var-file=environments/prod/terraform.tfvars

# 3. Apply
terraform apply -var-file=environments/prod/terraform.tfvars

# 4. Import resources hiện có (nếu cần)
terraform import module.compute.google_compute_instance.instances["translation01"] projects/<PROJECT_ID>/zones/asia-southeast1-a/instances/translation01
terraform import module.compute.google_compute_instance.instances["translation02"] projects/<PROJECT_ID>/zones/asia-southeast1-b/instances/translation02
terraform import module.compute.google_compute_instance.instances["translation03"] projects/<PROJECT_ID>/zones/asia-southeast1-b/instances/translation03
```

### State Backend

State được lưu trong GCS bucket `jbcalling-tf-state`:

```bash
# Tạo bucket trước khi init (one-time)
gsutil mb -p <PROJECT_ID> -l asia-southeast1 gs://jbcalling-tf-state
gsutil versioning set on gs://jbcalling-tf-state
```

### Modules

| Module | Resources |
|--------|-----------|
| network | VPC, subnet asia-southeast1 |
| firewall | SSH, HTTP/S, K8s API, WebRTC UDP, TURN, Calico VXLAN, NodePort |
| compute | 3 GCE instances, static external IPs, boot disks, labels, service account |
| dns | Cloud DNS zone, A records cho jbcalling.site + subdomains |

## Ansible

### Cấu trúc

```
infrastructure/ansible/
├── ansible.cfg                # Config (inventory, SSH, privilege escalation)
├── inventory/
│   └── prod/
│       └── hosts.yml          # 3 hosts: control-plane + workers
├── playbooks/
│   └── site.yml               # Master playbook
└── roles/
    ├── kubeadm-prereqs/       # Swap off, kernel modules, containerd, kubeadm
    ├── control-plane/         # kubeadm init, kubeconfig, untaint, label
    ├── worker/                # kubeadm join, label
    └── calico/                # Apply Calico CNI manifest
```

### Sử dụng

```bash
cd infrastructure/ansible

# 1. Test connectivity
ansible all -m ping

# 2. Chạy full setup
ansible-playbook playbooks/site.yml

# 3. Chỉ chạy role cụ thể
ansible-playbook playbooks/site.yml --tags kubeadm-prereqs
```

### Roles

| Role | Mô tả |
|------|-------|
| kubeadm-prereqs | Disable swap, load kernel modules (overlay, br_netfilter), sysctl, install containerd + kubeadm v1.31 |
| control-plane | kubeadm init, copy admin.conf, remove NoSchedule taint, label node |
| calico | kubectl apply Calico manifest, wait for calico-node Ready |
| worker | kubeadm join, label node với `instance=<hostname>` |

### Sau khi chạy xong

```bash
# Verify cluster
kubectl get nodes
# NAME            STATUS   ROLES           AGE   VERSION
# translation01   Ready    control-plane   5m    v1.31.x
# translation02   Ready    <none>          3m    v1.31.x
# translation03   Ready    <none>          3m    v1.31.x

# Verify labels
kubectl get nodes --show-labels | grep instance
```
