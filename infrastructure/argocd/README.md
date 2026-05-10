# Argo CD – GitOps Deployment

This directory contains all Argo CD configuration for the JBCalling platform, organized using the **App-of-Apps** pattern.

## Directory Structure

```
infrastructure/argocd/
├── bootstrap/                    # One-time setup resources
│   ├── namespace.yaml            # argocd namespace
│   ├── install.yaml              # Installation instructions
│   └── README.md                 # Step-by-step bootstrap guide
├── app-of-apps.yaml              # Root Application (manages all child apps)
├── applications/                 # Child Application manifests
│   ├── platform-cert-manager.yaml
│   ├── platform-traefik.yaml
│   ├── platform-sealed-secrets.yaml
│   ├── platform-monitoring.yaml
│   ├── platform-loki.yaml
│   ├── platform-velero.yaml
│   └── jbcalling-prod.yaml
└── README.md                     # This file
```

## Architecture

### App-of-Apps Pattern

A single root `Application` (`app-of-apps.yaml`) watches the `applications/` directory and automatically creates/manages all child Applications:

- **Platform components** (auto-sync enabled): cert-manager, Traefik, sealed-secrets, kube-prometheus-stack, loki-stack, Velero
- **Application workloads** (manual sync): jbcalling-prod

### Sync Policies

| Application | Auto-Sync | Self-Heal | Rationale |
|---|---|---|---|
| Platform components | Yes | Yes | Infrastructure should converge automatically |
| jbcalling-prod | No | No | Production app deployments require manual approval |

## Usage

### Initial Setup

See [bootstrap/README.md](bootstrap/README.md) for first-time cluster setup.

### Deploying a New Version

1. CI pushes a new image to `ghcr.io` with tag `sha-<commit>`
2. Update the image tag in `infrastructure/helm/jbcalling/values-prod.yaml`
3. Commit and push to `main`
4. Argo CD detects the drift and shows "OutOfSync"
5. Manually sync via UI or CLI:

```bash
argocd app sync jbcalling-prod
```

### Adding a New Platform Component

1. Create a Helm values file in `infrastructure/platform/<component>/values.yaml`
2. Create an Argo CD Application manifest in `infrastructure/argocd/applications/platform-<component>.yaml`
3. Commit and push — the App-of-Apps will pick it up automatically

### Troubleshooting

```bash
# Check application status
argocd app get <app-name>

# View sync history
argocd app history <app-name>

# Force refresh from Git
argocd app get <app-name> --refresh

# View application logs
argocd app logs <app-name>
```
