# Runbook Vận hành Kubernetes

**Version**: 1.0
**Last Updated**: 2026-05-05

## Kiểm tra trạng thái cluster

```bash
# Nodes
kubectl get nodes -o wide

# Tất cả pods
kubectl get pods -A

# Pods trong namespace app
kubectl get pods -n jbcalling-prod

# Events gần đây
kubectl get events -n jbcalling-prod --sort-by='.lastTimestamp' | tail -20
```

## Quản lý Services

### Xem logs

```bash
# Logs gateway
kubectl logs -n jbcalling-prod -l app.kubernetes.io/name=gateway -f

# Logs STT (tail 100 dòng)
kubectl logs -n jbcalling-prod -l app.kubernetes.io/name=stt --tail=100

# Logs container cụ thể
kubectl logs -n jbcalling-prod <pod-name> -c <container-name>
```

### Restart service

```bash
# Rolling restart
kubectl rollout restart deployment/gateway -n jbcalling-prod

# Kiểm tra rollout status
kubectl rollout status deployment/gateway -n jbcalling-prod
```

### Scale

```bash
# Scale frontend lên 5 replicas
kubectl scale deployment/frontend --replicas=5 -n jbcalling-prod

# Xem resource usage
kubectl top pods -n jbcalling-prod
kubectl top nodes
```

## Rollback

### Qua Argo CD UI

1. Mở Argo CD UI (https://argocd.jbcalling.site hoặc port-forward)
2. Chọn application `jbcalling-prod`
3. Click **History and Rollback**
4. Chọn revision cần rollback → **Rollback**

### Qua CLI

```bash
# Xem lịch sử
argocd app history jbcalling-prod

# Rollback về revision cụ thể
argocd app rollback jbcalling-prod <REVISION>

# Hoặc dùng Helm trực tiếp
helm rollback jbcalling -n jbcalling-prod
```

## Troubleshooting

### Pod không start được

```bash
# Xem events
kubectl describe pod <pod-name> -n jbcalling-prod

# Các nguyên nhân phổ biến:
# - ImagePullBackOff: sai image tag hoặc thiếu imagePullSecrets
# - Pending: không đủ resources hoặc nodeSelector không match
# - CrashLoopBackOff: app crash, xem logs
```

### Gateway (MediaSoup) không nhận WebRTC traffic

```bash
# Verify pod dùng hostNetwork
kubectl get pod -n jbcalling-prod -l app.kubernetes.io/name=gateway -o jsonpath='{.items[0].spec.hostNetwork}'
# Output: true

# Verify ANNOUNCED_IP đúng
kubectl exec -n jbcalling-prod -l app.kubernetes.io/name=gateway -- env | grep ANNOUNCED_IP

# Verify firewall GCP mở UDP 40000-40019
gcloud compute firewall-rules describe jbcalling-allow-webrtc
```

### Coturn không hoạt động

```bash
# Verify hostNetwork
kubectl get pod -n jbcalling-prod -l app.kubernetes.io/name=coturn -o jsonpath='{.items[0].spec.hostNetwork}'

# Test TURN
turnutils_uclient -e <TURN_IP> -p 3478 -u videocall -w <TURN_SECRET>

# Kiểm tra port binding
kubectl exec -n jbcalling-prod -l app.kubernetes.io/name=coturn -- netstat -ulnp | grep 3478
```

### Cert-manager / TLS issues

```bash
# Xem certificates
kubectl get certificates -A

# Xem certificate requests
kubectl get certificaterequests -A

# Xem challenges (nếu đang pending)
kubectl get challenges -A

# Describe certificate để xem lỗi
kubectl describe certificate <name> -n <namespace>
```

### Storage / PVC issues

```bash
# Xem PVCs
kubectl get pvc -n jbcalling-prod

# Xem PVs
kubectl get pv

# Nếu PVC Pending, kiểm tra StorageClass
kubectl get storageclass
kubectl describe pvc <pvc-name> -n jbcalling-prod
```

## Backup & Restore (Velero)

### Tạo backup thủ công

```bash
# Backup toàn bộ namespace
velero backup create jbcalling-backup-$(date +%Y%m%d) \
  --include-namespaces jbcalling-prod \
  --wait

# Xem danh sách backups
velero backup get
```

### Restore

```bash
# Restore từ backup
velero restore create --from-backup jbcalling-backup-20260505

# Xem restore status
velero restore get
```

## Sealed Secrets

### Tạo sealed secret mới

```bash
# 1. Tạo secret YAML bình thường
kubectl create secret generic my-secret \
  --from-literal=key=value \
  --dry-run=client -o yaml > secret.yaml

# 2. Seal nó
kubeseal --controller-namespace sealed-secrets \
  --controller-name sealed-secrets \
  -o yaml < secret.yaml > sealed-secret.yaml

# 3. Commit sealed-secret.yaml vào repo
# 4. Argo CD sẽ tự apply
```

## Monitoring

### Access dashboards

```bash
# Grafana (nếu chưa có ingress)
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80

# Prometheus
kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090

# Argo CD
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Kiểm tra metrics

```bash
# Service health
curl -s http://localhost:8002/health  # STT
curl -s http://localhost:8005/health  # Translation
curl -s http://localhost:8004/health  # TTS
curl -s http://localhost:3000/health  # Gateway
```

## Cập nhật K8s cluster

```bash
# Trên control-plane (translation01)
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.31.x

# Trên mỗi worker
sudo kubeadm upgrade node
sudo systemctl restart kubelet
```
