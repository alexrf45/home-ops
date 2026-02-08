# Adminer Deployment Guide
## Aligned with Your Home Lab Goals

This deployment guide specifically addresses your objectives around:
- Reproducible cluster configuration
- Independent worker node scaling
- Database monitoring
- Logging aggregation
- Security tooling integration

## Quick Start

### 1. Deploy Adminer

```bash
# Apply manifests via Flux (recommended)
kubectl apply -f flux-kustomization.yaml

# Or apply directly
kubectl apply -k .
```

**Note**: The deployment uses SHA256 image digests for security. See `IMAGE-DIGEST-GUIDE.md` for managing digest updates.

### 2. Verify Deployment

```bash
# Check pod status
kubectl get pods -n adminer

# Check Gateway API route
kubectl get httproute adminer -n adminer -o yaml

# View logs
kubectl logs -n adminer -l app=adminer --tail=50
```

## Integration with Your Infrastructure

### Storage Persistence

Adminer is stateless and doesn't require persistent storage. However, if you want to persist session data or uploaded SQL files:

```yaml
# Add PVC using Democratic CSI
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: adminer-data
  namespace: adminer
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: freenas-iscsi-csi  # Your TrueNAS storage class
  resources:
    requests:
      storage: 1Gi

# Mount in deployment
volumes:
- name: data
  persistentVolumeClaim:
    claimName: adminer-data

volumeMounts:
- name: data
  mountPath: /var/www/html/upload
```

### Worker Node Scaling Compatibility

Adminer's configuration supports your worker node scaling goals:

**Stateless Design**: Adminer can run on any worker node without data persistence concerns

**Pod Anti-Affinity** (Optional for HA):
```yaml
spec:
  template:
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: adminer
              topologyKey: kubernetes.io/hostname
```

**Node Selector** (if needed):
```yaml
spec:
  template:
    spec:
      nodeSelector:
        node-role.kubernetes.io/worker: ""
```

This ensures Adminer respects your Terraform-managed worker node lifecycle without disruption.

### Database Monitoring Integration

#### CloudNativePG Monitoring

Adminer complements CloudNativePG's built-in monitoring. Connect to PostgreSQL metrics:

1. **View Database Performance**:
   - Access Adminer → Connect to PostgreSQL
   - Query `pg_stat_database` for database statistics
   - Query `pg_stat_activity` for active connections

2. **Create Monitoring Queries**:
   ```sql
   -- Long-running queries
   SELECT pid, age(clock_timestamp(), query_start), usename, query 
   FROM pg_stat_activity 
   WHERE query != '<IDLE>' AND query NOT ILIKE '%pg_stat_activity%' 
   ORDER BY query_start desc;
   
   -- Database size
   SELECT pg_database.datname, 
          pg_size_pretty(pg_database_size(pg_database.datname)) AS size 
   FROM pg_database 
   ORDER BY pg_database_size(pg_database.datname) DESC;
   
   -- Table bloat
   SELECT schemaname, tablename, 
          pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
   FROM pg_tables 
   ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
   ```

3. **Export Queries to Prometheus**:
   Create PostgreSQL exporter queries based on Adminer insights.

#### MinIO S3 Backend Monitoring

For your backup strategy using MinIO:

1. **S3 Connection in Adminer**:
   Adminer doesn't natively support S3, but you can:
   - Use Adminer for PostgreSQL direct access
   - Use MinIO Console for S3 bucket monitoring
   - Query PostgreSQL backup status tables

2. **Backup Verification Queries**:
   ```sql
   -- CloudNativePG backup status
   SELECT name, status, start_time, end_time 
   FROM backup_status 
   ORDER BY start_time DESC;
   ```

### Logging Aggregation Setup

#### Vector Integration (Recommended)

Based on the Vector configuration provided:

1. **Deploy Vector DaemonSet** with Adminer pipeline:
   ```bash
   kubectl apply -f vector-logging.yaml
   ```

2. **Configure External Syslog Server**:
   Edit `vector-logging.yaml`:
   ```yaml
   external_syslog:
     address: "your-syslog-server.external.local:514"
   ```

3. **Verify Log Collection**:
   ```bash
   # Check Vector is collecting Adminer logs
   kubectl logs -n logging daemonset/vector | grep adminer
   
   # Query logs in Loki
   kubectl port-forward -n logging svc/loki 3100:3100
   # Browse to http://localhost:3100
   # Query: {namespace="adminer"}
   ```

#### Fluent Bit Alternative

If you prefer Fluent Bit:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
  namespace: logging
data:
  custom_parsers.conf: |
    [PARSER]
        Name   adminer
        Format json
        Time_Key time
        Time_Format %Y-%m-%dT%H:%M:%S.%L
  
  filters.conf: |
    [FILTER]
        Name kubernetes
        Match kube.*
        Kube_URL https://kubernetes.default.svc:443
        Kube_CA_File /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        Kube_Token_File /var/run/secrets/kubernetes.io/serviceaccount/token
    
    [FILTER]
        Name grep
        Match kube.*
        Regex $kubernetes['namespace_name'] ^adminer$
  
  outputs.conf: |
    [OUTPUT]
        Name syslog
        Match kube.*
        Host your-syslog-server.external.local
        Port 514
        Mode tcp
```

### Security Tooling Integration

#### Trivy Operator for Image Scanning

1. **Install Trivy Operator**:
   ```bash
   helm repo add aqua https://aquasecurity.github.io/helm-charts/
   helm install trivy-operator aqua/trivy-operator \
     --namespace trivy-system --create-namespace
   ```

2. **Scan Adminer Image**:
   ```bash
   kubectl get vulnerabilityreports -n adminer
   kubectl describe vulnerabilityreport -n adminer
   ```

3. **Apply Security Policy** (optional):
   ```bash
   kubectl apply -f security-scanning.yaml
   ```

#### Falco Runtime Security

1. **Install Falco**:
   ```bash
   helm repo add falcosecurity https://falcosecurity.github.io/charts
   helm install falco falcosecurity/falco \
     --namespace falco-system --create-namespace \
     --set falcosidekick.enabled=true
   ```

2. **Deploy Custom Rules**:
   ```bash
   kubectl apply -f falco-rules.yaml
   ```

3. **Monitor Security Events**:
   ```bash
   # View Falco alerts
   kubectl logs -n falco-system -l app.kubernetes.io/name=falco -f
   
   # Check FalcoSidekick for aggregated alerts
   kubectl logs -n falco-system -l app.kubernetes.io/name=falcosidekick -f
   ```

#### Network Policy Enforcement

Your NetworkPolicy restricts Adminer traffic. To verify:

```bash
# Test connectivity from Adminer pod
kubectl exec -it -n adminer deploy/adminer -- sh
nc -zv postgres-rw.database.svc.cluster.local 5432  # Should succeed
nc -zv google.com 443  # Should fail (egress restricted)
```

## GitOps Workflow with Flux

### Repository Structure

Organize your Git repository:

```
apps/
├── adminer/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── httproute.yaml
│   ├── networkpolicy.yaml
│   ├── servicemonitor.yaml
│   └── kustomization.yaml
└── monitoring/
    └── adminer-dashboard.yaml
```

### Flux Kustomization

```yaml
# flux-system/kustomizations.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: adminer
  namespace: flux-system
spec:
  interval: 10m
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./apps/adminer
  prune: true
  wait: true
  healthChecks:
    - apiVersion: apps/v1
      kind: Deployment
      name: adminer
      namespace: adminer
  postBuild:
    substituteFrom:
      - kind: Secret
        name: cluster-vars
```

### SOPS Integration (if needed)

For sensitive configuration:

```bash
# Encrypt secrets
sops --encrypt --age <your-age-key> secrets.yaml > secrets.enc.yaml

# Add to Flux Kustomization
spec:
  decryption:
    provider: sops
    secretRef:
      name: sops-age
```

## Terraform Integration

### Cluster Lifecycle Management

Your Terraform code manages the cluster. Adminer deployment is independent:

**Cluster Creation** → **Flux Bootstrap** → **Adminer Deployed**

```hcl
# Example: Talos cluster module
module "talos_cluster" {
  source = "./modules/talos"
  
  control_plane_nodes = 3
  worker_nodes        = var.worker_count  # Scalable via Terraform
  
  # Adminer runs on workers - scaling workers doesn't affect Adminer
}

# Flux bootstrap
resource "null_resource" "flux_bootstrap" {
  depends_on = [module.talos_cluster]
  
  provisioner "local-exec" {
    command = "flux bootstrap github --path=clusters/production"
  }
}
```

### Scaling Workers

```bash
# Update Terraform variable
terraform apply -var="worker_count=5"  # Scale from 3 to 5 workers

# Adminer pods will naturally redistribute via Kubernetes scheduler
kubectl get pods -n adminer -o wide  # Verify pod placement
```

## Monitoring Dashboard Access

### Grafana Dashboard

1. **Import Dashboard**:
   ```bash
   kubectl apply -f monitoring-dashboard.yaml
   ```

2. **Access Grafana**:
   ```bash
   kubectl port-forward -n monitoring svc/grafana 3000:3000
   ```
   
   Browse to: http://localhost:3000
   Dashboard: "Adminer Database Management"

3. **Key Metrics**:
   - Database connection rate
   - Query throughput
   - Security alerts
   - Resource usage
   - Authentication failures

### Prometheus Alerts

Alerts are configured in `monitoring-dashboard.yaml`:

- `AdminerHighSecurityAlerts`: Security events detected
- `AdminerPodDown`: Pod unavailability
- `AdminerHighMemoryUsage`: Resource constraints
- `AdminerAuthenticationFailures`: Suspicious login attempts
- `AdminerSQLInjectionAttempt`: Critical security event

## Backup and Recovery

While Adminer itself is stateless, secure your database access:

### Backup Adminer Configuration

```bash
# Export current configuration
kubectl get -n adminer deployment,service,httproute,networkpolicy -o yaml > adminer-backup.yaml

# Store in Git repository (already done with GitOps!)
```

### Disaster Recovery

```bash
# Cluster destroyed and recreated
# Flux automatically redeploys Adminer
flux reconcile kustomization adminer --with-source

# Verify deployment
kubectl get pods -n adminer
kubectl get httproute adminer -n adminer
```

## Performance Tuning

### For High Database Query Volume

```yaml
spec:
  replicas: 3  # Scale horizontally
  
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi
```

### Connection Pooling

Adminer doesn't pool connections. For production, consider:
- PgBouncer for PostgreSQL connection pooling
- ProxySQL for MySQL connection pooling

## Security Hardening Checklist

- [x] Pod Security Standards (Restricted)
- [x] Read-only root filesystem
- [x] Non-root user (UID 1000)
- [x] Capabilities dropped (ALL)
- [x] NetworkPolicy for ingress/egress
- [x] Resource limits defined
- [x] Liveness/readiness probes
- [x] Trivy scanning enabled
- [x] Falco runtime monitoring
- [x] Logging to external server
- [ ] Authentication proxy (deploy OAuth2 Proxy)
- [ ] mTLS with service mesh (consider adding Cilium mesh)
- [ ] Audit logging enabled

## Troubleshooting

### Common Issues

**1. Cannot connect to databases**
```bash
# Check NetworkPolicy
kubectl describe networkpolicy adminer -n adminer

# Test connectivity
kubectl exec -n adminer deploy/adminer -- nc -zv postgres-rw.database.svc.cluster.local 5432
```

**2. Gateway API route not working**
```bash
# Check HTTPRoute status
kubectl get httproute adminer -n adminer -o yaml

# Verify Cilium Gateway
kubectl get gateway -n kube-system
```

**3. High memory usage**
```bash
# Check resource usage
kubectl top pod -n adminer

# Increase limits if needed
kubectl patch deployment adminer -n adminer -p '{"spec":{"template":{"spec":{"containers":[{"name":"adminer","resources":{"limits":{"memory":"512Mi"}}}]}}}}'
```

## Next Steps

1. **Deploy Monitoring Stack** (if not already deployed):
   ```bash
   helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
     --namespace monitoring --create-namespace
   ```

2. **Configure External Logging**:
   - Update Vector/Fluent Bit with your syslog server address
   - Verify log forwarding

3. **Add Authentication**:
   - Deploy OAuth2 Proxy or Authelia
   - Configure authentication in front of Adminer

4. **Enable mTLS** (optional):
   - Use Cilium service mesh
   - Encrypt all traffic between services

5. **Regular Maintenance**:
   - Update Adminer image regularly
   - Review security scan results
   - Monitor Falco alerts
   - Audit database access logs

## Resources

- [Adminer Documentation](https://www.adminer.org/)
- [Your GitOps Repository](https://github.com/your-org/flux-config)
- [Talos Linux Docs](https://www.talos.dev/)
- [Cilium Gateway API](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/)
- [CloudNativePG](https://cloudnative-pg.io/)
- [Trivy Operator](https://aquasecurity.github.io/trivy-operator/)
- [Falco](https://falco.org/)
