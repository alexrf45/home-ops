# Adminer Deployment for Kubernetes

This directory contains Kubernetes manifests for deploying [Adminer](https://www.adminer.org/), a full-featured database management tool, with security hardening and GitOps integration.

## Overview

Adminer is deployed with the following security features:
- **Restricted Pod Security Standards**: Enforced at namespace level
- **Read-only root filesystem**: Prevents runtime modifications
- **Non-root user**: Runs as UID 1000
- **Dropped capabilities**: All Linux capabilities dropped
- **Resource limits**: CPU and memory constraints
- **Network policies**: Restricts ingress/egress traffic
- **Security context**: seccomp profile and privilege escalation prevention

## Files

- `namespace.yaml` - Namespace with Pod Security Standards
- `deployment.yaml` - Adminer deployment with security hardening
- `service.yaml` - ClusterIP service
- `httproute.yaml` - Gateway API HTTPRoute for ingress
- `networkpolicy.yaml` - Network policy for traffic control
- `servicemonitor.yaml` - Prometheus ServiceMonitor (optional)
- `kustomization.yaml` - Kustomize configuration
- `flux-kustomization.yaml` - Flux CD Kustomization

## Prerequisites

- Kubernetes cluster with Gateway API support (Cilium)
- Flux CD installed and configured
- Prometheus Operator (optional, for monitoring)
- Trivy Operator (optional, for container scanning)

## Configuration

### 1. Update HTTPRoute Hostname

Edit `httproute.yaml`:
```yaml
hostnames:
- "adminer.yourdomain.local"  # Replace with your actual hostname
```

### 2. Update Gateway Reference

If your Gateway is not named `cilium-gateway` in `kube-system` namespace:
```yaml
parentRefs:
- name: your-gateway-name
  namespace: your-gateway-namespace
```

### 3. Configure Database Access (Optional)

To pre-configure a default database server, edit `deployment.yaml`:
```yaml
env:
- name: ADMINER_DEFAULT_SERVER
  value: "postgres-db.database.svc.cluster.local"
```

### 4. Adjust Network Policy

If your databases are in specific namespaces, update `networkpolicy.yaml`:
```yaml
- to:
  - namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: your-database-namespace
```

## Deployment

### Option 1: GitOps with Flux CD (Recommended)

1. Add manifests to your Git repository:
   ```bash
   git add apps/adminer/
   git commit -m "Add Adminer deployment"
   git push
   ```

2. Apply the Flux Kustomization:
   ```bash
   kubectl apply -f flux-kustomization.yaml
   ```

3. Verify deployment:
   ```bash
   flux get kustomizations adminer
   kubectl get pods -n adminer
   ```

### Option 2: Direct kubectl

```bash
kubectl apply -k .
```

## Security Considerations

### Container Image Scanning

With Trivy Operator installed, scan the Adminer image:
```bash
kubectl get vulnerabilityreports -n adminer
```

The deployment includes annotations for Trivy to track vulnerabilities:
```yaml
annotations:
  trivy.security.devops.com/medium: "0"
  trivy.security.devops.com/low: "0"
```

### Access Control

**Important**: Adminer provides direct database access without authentication. Consider:

1. **Add authentication layer**: Deploy behind an authenticating proxy (OAuth2 Proxy, Authelia)
2. **Restrict access**: Use NetworkPolicy to limit which pods can reach Adminer
3. **Use read-only database users**: Create database users with minimal permissions
4. **Enable audit logging**: Monitor all database access through Adminer

### Example: Deploy with OAuth2 Proxy

Create a separate HTTPRoute for authenticated access:
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: adminer-auth
  namespace: adminer
spec:
  parentRefs:
  - name: cilium-gateway
    namespace: kube-system
  hostnames:
  - "adminer.yourdomain.local"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    filters:
    - type: RequestRedirect
      requestRedirect:
        host: oauth2-proxy.auth.svc.cluster.local
        port: 4180
```

## Monitoring

### Prometheus Metrics

While Adminer doesn't expose native Prometheus metrics, you can monitor:
- HTTP endpoint availability (via ServiceMonitor)
- Container resource usage (via cAdvisor)
- Application logs (via logging aggregation)

### Adding Metrics Exporter Sidecar

To add detailed metrics, deploy a sidecar exporter:

```yaml
- name: metrics-exporter
  image: nginx/nginx-prometheus-exporter:latest
  args:
  - -nginx.scrape-uri=http://localhost:8080/stub_status
  ports:
  - name: metrics
    containerPort: 9113
```

## Logging

### Integration with Logging Stack

Deploy Vector or Fluent Bit DaemonSet to collect logs:

```yaml
# Vector configuration snippet
sources:
  adminer_logs:
    type: kubernetes_logs
    namespace_annotation_fields:
      namespace_labels: ""
    pod_annotation_fields:
      pod_labels: ""
    extra_label_selector: "app=adminer"

transforms:
  adminer_parsed:
    type: remap
    inputs:
      - adminer_logs
    source: |
      . = parse_json!(.message)
      .namespace = "adminer"
```

### Audit Logging for Database Access

Enable PostgreSQL audit logging on databases accessed via Adminer:

```yaml
# CloudNativePG Cluster example
spec:
  postgresql:
    parameters:
      log_statement: "all"
      log_connections: "on"
      log_disconnections: "on"
```

## Database Connection Examples

### PostgreSQL (CloudNativePG)

1. Get database credentials:
   ```bash
   kubectl get secret postgres-app -n database -o jsonpath='{.data.password}' | base64 -d
   ```

2. In Adminer:
   - System: PostgreSQL
   - Server: `postgres-rw.database.svc.cluster.local`
   - Username: `app`
   - Password: (from secret)
   - Database: `app`

### MySQL

- Server: `mysql.database.svc.cluster.local`
- Port: `3306`

### MongoDB

- Server: `mongodb://mongo.database.svc.cluster.local:27017`

## Troubleshooting

### Pod fails to start

Check security context:
```bash
kubectl describe pod -n adminer -l app=adminer
```

### Cannot connect to databases

1. Check NetworkPolicy:
   ```bash
   kubectl describe networkpolicy adminer -n adminer
   ```

2. Test connectivity:
   ```bash
   kubectl exec -it -n adminer deploy/adminer -- sh
   nc -zv postgres-rw.database.svc.cluster.local 5432
   ```

### Gateway API route not working

Check HTTPRoute status:
```bash
kubectl describe httproute adminer -n adminer
```

Verify Gateway listeners:
```bash
kubectl get gateway cilium-gateway -n kube-system -o yaml
```

## Scaling and High Availability

For production use, scale Adminer horizontally:

```yaml
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 1
```

Note: Adminer is stateless, so scaling is straightforward.

## Cleanup

### Remove via Flux
```bash
kubectl delete kustomization adminer -n flux-system
```

### Remove directly
```bash
kubectl delete -k .
```

## Additional Resources

- [Adminer Documentation](https://www.adminer.org/)
- [Gateway API Documentation](https://gateway-api.sigs.k8s.io/)
- [Cilium Gateway API Guide](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/)
- [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [CloudNativePG Documentation](https://cloudnative-pg.io/)

## Security Best Practices

1. **Regularly update the image**: Monitor for CVEs and update to latest version
2. **Use image digests**: Pin to specific SHA256 digests for reproducibility
3. **Enable Pod Security Admission**: Already configured at namespace level
4. **Implement RBAC**: Create service account with minimal permissions if needed
5. **Use external secrets**: Integrate with SOPS/age for sensitive configuration
6. **Enable audit logging**: Track all administrative actions
7. **Deploy behind authentication**: Never expose directly to the internet
8. **Use read-only database users**: Minimize blast radius of compromised credentials
9. **Implement network segmentation**: Use NetworkPolicies extensively
10. **Monitor access patterns**: Alert on unusual database access patterns
