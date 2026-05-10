# Kế hoạch Migration Docker Swarm → Kubernetes

**Version**: 1.0
**Status**: In Progress
**Last Updated**: 2026-05-05

## Tổng quan

Chuyển hệ thống JB Calling từ Docker Swarm (3 GCE instances) sang Kubernetes self-managed (kubeadm) trên đúng 3 instance hiện có tại Google Cloud, kèm IaC bằng Terraform + Ansible, đóng gói app bằng Helm, và CI/CD theo mô hình GitHub Actions (CI) + Argo CD (GitOps CD).

## Bộ công cụ

| Mục đích | Công cụ | Lý do chọn |
|----------|---------|-------------|
| K8s Distribution | kubeadm v1.31 | Self-managed, không phí cluster GKE ($73/tháng) |
| CNI | Calico | NetworkPolicy support, ổn định, đơn giản |
| Container Runtime | containerd | Standard cho kubeadm, nhẹ hơn Docker |
| IaC Hạ tầng | Terraform | Quản lý GCP resources declaratively |
| IaC K8s Bootstrap | Ansible | Tự động hoá kubeadm init/join, idempotent |
| App Packaging | Helm 3 | Umbrella chart + subcharts, dễ rollback |
| Ingress Controller | Traefik v3 | Giữ thói quen từ Swarm, CRD IngressRoute |
| TLS | cert-manager + Let's Encrypt | Auto-renewal, HTTP01 challenge |
| Container Registry | ghcr.io | Free, tích hợp GitHub Actions |
| CI | GitHub Actions | Repo đã có .github/, free cho public repo |
| CD (GitOps) | Argo CD | App-of-Apps, UI trực quan, rollback dễ |
| Secrets | Sealed Secrets (Bitnami) | Commit sealed YAML vào repo, không cần GCP Secret Manager |
| Storage | GCE PD CSI | StorageClass pd-balanced cho stateful services |
| Monitoring | kube-prometheus-stack + Loki | Thay thế stack monitoring hiện tại |
| Backup | Velero + GCS | Backup namespace + PVC snapshots |
| Image Scan | Trivy | Quét vulnerability trong CI |

## Kiến trúc Target

### Node Layout

- **translation01** (control-plane + worker): Traefik, Frontend, Gateway (hostNetwork), Redis, Prometheus, Alertmanager, Argo CD
- **translation02** (worker): STT, Translation, TTS, Redis Gateway, Coturn (hostNetwork)
- **translation03** (worker): TTS (replica 2), Grafana, Loki

### Đặc biệt: WebRTC trên K8s

- `gateway` pod dùng `hostNetwork: true` + `dnsPolicy: ClusterFirstWithHostNet` để MediaSoup SFU bind trực tiếp UDP 40000-40019 trên node IP
- `coturn` pod dùng `hostNetwork: true` để TURN server bind TCP/UDP 3478, 5349, UDP 49152-49156
- Firewall GCP (Terraform) mở các port này cho `0.0.0.0/0` (WebRTC cần public access)

### CI/CD Flow

```
Developer push → GitHub Actions CI
  → Build Docker image
  → Scan with Trivy
  → Push to ghcr.io
  → Auto-PR bump image tag in values-prod.yaml
  → Merge PR → Argo CD detects change
  → Argo CD syncs to K8s cluster
```

## Roadmap

| Phase | Nội dung | Deliverable |
|-------|----------|-------------|
| 0 | Base layout repo | PR khởi tạo infrastructure/ |
| 1 | Terraform | VPC, firewall, GCE, DNS, GCS managed |
| 2 | Ansible + kubeadm | K8s cluster 3 nodes Ready |
| 3 | Platform Helm | cert-manager, traefik, sealed-secrets, monitoring, velero |
| 4 | App Helm chart | Umbrella jbcalling chart + sealed secrets |
| 5 | GitHub Actions CI | Build → ghcr → scan → auto PR |
| 6 | Staging test | Deploy on k8s.jbcalling.site, smoke test |
| 7 | Production cutover | DNS switch, 7-day monitoring, decommission Swarm |

## Rủi ro

1. **Single control-plane (SPOF)**: Chấp nhận cho đồ án, document trade-off
2. **RAM trên translation01**: Control-plane + etcd chiếm ~1.2G, monitor sát
3. **WebRTC hostNetwork**: Cần verify `ANNOUNCED_IP` đúng public IP của node
4. **DNS cutover**: Hạ TTL xuống 60s trước 24-48h

## Tài liệu liên quan

- [14-CICD.md](14-CICD.md) - Hướng dẫn CI/CD pipeline
- [15-IAC-TERRAFORM.md](15-IAC-TERRAFORM.md) - Hướng dẫn Terraform/Ansible
- [16-RUNBOOK-K8S.md](16-RUNBOOK-K8S.md) - Runbook vận hành K8s
