# Ansible – Kubernetes Cluster Provisioning

Provisions a **kubeadm v1.31** cluster with **containerd** runtime and **Calico** CNI on 3 GCE instances (Ubuntu 22.04).

## Cluster topology

| Host           | External IP      | Role                | Label                  |
|----------------|------------------|---------------------|------------------------|
| translation01  | 35.198.221.169   | control-plane + worker | `instance=translation01` |
| translation02  | 34.126.152.20    | worker              | `instance=translation02` |
| translation03  | 34.158.47.145    | worker              | `instance=translation03` |

- **Pod CIDR:** `10.244.0.0/16`
- **Service CIDR:** `10.96.0.0/12`
- **API endpoint:** `translation01:6443`

## Prerequisites

- Ansible ≥ 2.15 on the control machine.
- SSH access to all 3 instances as user `ubuntu` with sudo privileges.
- Python 3 available on every target (`/usr/bin/python3`).

## Quick start

```bash
cd infrastructure/ansible

# Verify connectivity
ansible all -m ping

# Provision the full cluster
ansible-playbook playbooks/site.yml
```

## Playbook roles (execution order)

1. **kubeadm-prereqs** *(all nodes)* – disables swap, loads kernel modules, configures sysctl, installs containerd + kubeadm/kubelet/kubectl v1.31.
2. **control-plane** *(translation01)* – runs `kubeadm init`, copies kubeconfig, removes `NoSchedule` taint, labels node, generates join token.
3. **calico** *(translation01)* – applies the Calico CNI manifest and waits for pods to be running.
4. **worker** *(translation02, translation03)* – joins workers to the cluster via `kubeadm join`, labels each node.

## Re-running safely

All tasks are idempotent. Roles check whether the cluster or node has already been initialised before running destructive commands (`kubeadm init` / `kubeadm join`).

## Updating IPs

Edit `inventory/prod/hosts.yml` and replace the `ansible_host` values for each node.
