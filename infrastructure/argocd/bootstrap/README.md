# Argo CD Bootstrap

## Prerequisites

- A running Kubernetes cluster (v1.28+)
- `kubectl` configured with cluster-admin access
- `argocd` CLI installed ([install guide](https://argo-cd.readthedocs.io/en/stable/cli_installation/))

## Bootstrap Steps

### 1. Create the argocd namespace

```bash
kubectl apply -f infrastructure/argocd/bootstrap/namespace.yaml
```

### 2. Install Argo CD

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 3. Wait for all pods to be ready

```bash
kubectl -n argocd wait --for=condition=Ready pod --all --timeout=300s
```

### 4. Get the initial admin password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

### 5. Port-forward the Argo CD server (for local access)

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then open https://localhost:8080 and log in with user `admin` and the password from step 4.

### 6. Deploy the App-of-Apps root application

```bash
kubectl apply -f infrastructure/argocd/app-of-apps.yaml
```

This single Application resource deploys all platform components and the jbcalling application via the App-of-Apps pattern.

### 7. Change the default admin password

```bash
argocd login localhost:8080
argocd account update-password
```

## Useful Commands

```bash
# List all applications
argocd app list

# Sync a specific application
argocd app sync <app-name>

# Check application health
argocd app get <app-name>
```
