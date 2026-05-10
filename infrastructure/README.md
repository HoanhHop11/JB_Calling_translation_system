# Infrastructure

Thư mục này chứa toàn bộ cấu hình hạ tầng cho hệ thống JB Calling.

## Cấu trúc

```
infrastructure/
├── swarm/              # (Legacy) Docker Swarm stack - giữ làm fallback
├── traefik/            # (Legacy) Traefik dynamic config cho Swarm
├── terraform/          # IaC - quản lý hạ tầng GCP (VPC, firewall, GCE, DNS)
├── ansible/            # Bootstrap K8s cluster (kubeadm + containerd + Calico)
├── helm/
│   └── jbcalling/      # Umbrella Helm chart cho toàn bộ application
├── platform/           # Helm values cho platform components (cert-manager, traefik, monitoring, ...)
└── argocd/             # Argo CD bootstrap + Application manifests (GitOps)
```

## Thứ tự triển khai

1. **Terraform** - Tạo/import hạ tầng GCP (VPC, firewall, GCE instances, DNS, GCS buckets)
2. **Ansible** - Bootstrap K8s cluster trên 3 node (kubeadm init/join, Calico CNI)
3. **Platform** - Cài đặt platform components qua Argo CD (cert-manager, traefik, sealed-secrets, monitoring, velero)
4. **Helm/jbcalling** - Deploy application services qua Argo CD

## Cluster Architecture

```
translation01 (control-plane + worker)
├── Traefik (Ingress, hostNetwork 80/443)
├── Frontend (3 replicas)
├── Gateway (MediaSoup SFU, hostNetwork UDP 40000-40019)
├── Redis (main)
├── Prometheus + Alertmanager
└── Argo CD

translation02 (worker)
├── STT (NeMo Parakeet 0.6B)
├── Translation (VinAI)
├── TTS Piper (replica 1)
├── Redis Gateway
└── Coturn (TURN, hostNetwork TCP/UDP 3478, UDP 49152-49156)

translation03 (worker)
├── TTS Piper (replica 2)
├── Grafana
└── Loki
```
