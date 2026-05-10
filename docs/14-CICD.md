# CI/CD Pipeline - GitHub Actions + Argo CD

**Version**: 1.0
**Last Updated**: 2026-05-05

## Tổng quan

Hệ thống CI/CD sử dụng **GitHub Actions** cho Continuous Integration (build, test, scan, push image) và **Argo CD** cho Continuous Deployment theo mô hình GitOps (pull-based).

## Architecture

```
┌─────────────┐    push     ┌──────────────┐
│  Developer   │───────────►│  GitHub Repo  │
└─────────────┘             └──────┬───────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
                    ▼                             ▼
           ┌───────────────┐            ┌─────────────────┐
           │ GitHub Actions │            │  Argo CD (K8s)  │
           │     (CI)       │            │     (CD)        │
           └───────┬───────┘            └────────┬────────┘
                   │                             │
        ┌──────────┤                             │
        │          │                             │
        ▼          ▼                             ▼
┌────────────┐ ┌──────────┐            ┌─────────────────┐
│   ghcr.io  │ │ Auto-PR  │            │   K8s Cluster   │
│  (images)  │ │ bump tag │            │  (3 nodes GCE)  │
└────────────┘ └──────────┘            └─────────────────┘
```

## GitHub Actions Workflows

### 1. ci-services.yml — Build & Push Docker Images

**Trigger**: Push to `main` branch on `services/**`, PR on `services/**`

**Flow**:
1. Detect which service(s) changed (`dorny/paths-filter`)
2. Matrix build: chỉ build services có thay đổi
3. Build multi-platform image (linux/amd64) với Docker Buildx
4. Push to `ghcr.io/<owner>/jbcalling-<service>:<tag>`
5. Scan image với Trivy
6. (On main only) Auto-create PR to bump image tag in `values-prod.yaml`

**Tags**: `sha-<short-sha>`, `latest` (on main only)

### 2. ci-helm.yml — Validate Helm Charts

**Trigger**: PR on `infrastructure/helm/**`

**Flow**:
1. `helm lint infrastructure/helm/jbcalling`
2. `helm template` → render YAML
3. Validate với `kubeconform`

### 3. ci-terraform.yml — Validate Terraform

**Trigger**: PR on `infrastructure/terraform/**`

**Flow**:
1. `terraform fmt -check`
2. `terraform init -backend=false`
3. `terraform validate`

## Argo CD

### Bootstrap

```bash
# 1. Tạo namespace
kubectl create namespace argocd

# 2. Cài đặt Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. Lấy initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 4. Apply App-of-Apps
kubectl apply -f infrastructure/argocd/app-of-apps.yaml
```

### App-of-Apps Pattern

Root Application (`app-of-apps.yaml`) tự động tạo tất cả Application con từ `infrastructure/argocd/applications/`:

- **Platform (auto-sync)**: cert-manager, traefik, sealed-secrets, kube-prometheus-stack, loki, velero
- **Application (manual sync)**: jbcalling-prod

### Sync Policy

| Application | Sync Policy | Lý do |
|------------|------------|-------|
| Platform components | Auto-sync + self-heal | Infra ổn định, cần tự phục hồi |
| jbcalling-prod | Manual sync | Production safety, review trước khi deploy |

## GitHub Secrets Cần Cấu Hình

| Secret | Mô tả |
|--------|-------|
| `GITHUB_TOKEN` | Tự động có (ghcr.io login) |
| `GCP_SA_KEY` | Service Account JSON cho Terraform (nếu cần plan trong CI) |

## Quy trình Deploy Thực Tế

### Deploy service mới:

1. Sửa code trong `services/<tên>/`
2. Push lên branch, tạo PR → CI build + test
3. Merge PR → CI push image lên ghcr.io
4. CI tự tạo PR bump image tag trong `values-prod.yaml`
5. Review + merge PR values → Argo CD phát hiện thay đổi
6. Argo CD sync (manual cho prod) → K8s rolling update

### Rollback:

```bash
# Qua Argo CD UI: History → chọn revision cũ → Rollback
# Hoặc CLI:
argocd app rollback jbcalling-prod
```
