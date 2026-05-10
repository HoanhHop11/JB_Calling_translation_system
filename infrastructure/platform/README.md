# Platform Components

Helm values for third-party platform components deployed via Argo CD.

## Components

| Component | Namespace | Purpose |
|---|---|---|
| **cert-manager** | `cert-manager` | Automated TLS certificate management (Let's Encrypt) |
| **Traefik** | `traefik` | Ingress controller & reverse proxy (hostNetwork on translation01) |
| **sealed-secrets** | `kube-system` | Encrypt Kubernetes Secrets for safe Git storage |
| **kube-prometheus-stack** | `monitoring` | Prometheus, Grafana, Alertmanager, node-exporter |
| **loki-stack** | `monitoring` | Log aggregation (Loki) and collection (Promtail) |
| **Velero** | `velero` | Cluster backup & disaster recovery (GCP bucket) |

## Directory Layout

```
infrastructure/platform/
├── cert-manager/
│   └── values.yaml
├── traefik/
│   └── values.yaml
├── sealed-secrets/
│   └── values.yaml
├── kube-prometheus-stack/
│   └── values.yaml
├── loki-stack/
│   └── values.yaml
├── velero/
│   └── values.yaml
└── README.md
```

## How It Works

Each component's values file is referenced by its corresponding Argo CD Application in `infrastructure/argocd/applications/` using the multi-source pattern:

1. **Source 1**: The upstream Helm chart repository (e.g., `https://charts.jetstack.io`)
2. **Source 2**: This Git repository (referenced as `$values`) providing the custom values file

## Configuration Notes

### Traefik
- Uses `hostNetwork: true` to bind directly to ports 80/443 on the `translation01` node
- Let's Encrypt integration via TLS challenge — set the `email` field before deploying

### Monitoring (kube-prometheus-stack)
- Grafana pinned to `translation03` node via nodeSelector
- Prometheus retention: 30 days / 20 GB
- ServiceMonitor/PodMonitor auto-discovery enabled across all namespaces

### Loki
- Grafana is disabled (uses Grafana from kube-prometheus-stack)
- Log retention: 30 days

### Velero
- GCP plugin for Google Cloud Storage
- Daily backup at 02:00 UTC, retained for 30 days
- Backs up the `jbcalling` namespace

### Secrets & TODOs

Several values files contain `TODO` placeholders for sensitive data:

- `traefik/values.yaml` — Let's Encrypt email
- `kube-prometheus-stack/values.yaml` — Grafana admin password
- `velero/values.yaml` — GCP service account, project ID, credentials

Use **sealed-secrets** to encrypt these values before committing.
