# CloudNativePG Local Backup Options for TrueNAS

This guide covers two approaches for keeping PostgreSQL backups local on your TrueNAS infrastructure instead of cloud storage.

## Option Comparison

| Feature | MinIO (Option 1) | Volume Snapshots (Option 2) |
|---------|------------------|----------------------------|
| **Backup Speed** | Medium (network transfer) | Very Fast (block-level COW) |
| **Recovery Speed** | Medium | Very Fast |
| **Storage Efficiency** | Good (compression) | Excellent (ZFS dedup/compress) |
| **Portability** | High (S3-compatible) | Lower (tied to storage class) |
| **Setup Complexity** | Medium | Lower |
| **WAL Archiving** | Native Barman support | Requires separate config |
| **Point-in-Time Recovery** | Full support | Snapshot-based only |

**Recommendation**: Start with **Option 1 (MinIO)** for full PITR capability, or use **Option 2 (Volume Snapshots)** for simplicity and speed if daily snapshots meet your RPO requirements.

---

## Option 1: MinIO on TrueNAS

### Step 1: Deploy MinIO on TrueNAS Scale

1. **Create a Dataset for MinIO**
   ```
   Datasets > Add Dataset
   Name: minio
   Parent: your-pool/apps
   ```

2. **Install MinIO App**
   ```
   Apps > Discover Apps > MinIO
   ```
   
   Configuration:
   - **Root User**: `admin` (or your choice)
   - **Root Password**: Strong password
   - **API Port**: `9000`
   - **Console Port**: `9001`
   - **Storage**: Host Path pointing to your minio dataset
   - **Certificate**: `truenas_default` for HTTPS

3. **Create Backup Bucket**
   
   Access MinIO Console at `https://<truenas-ip>:9001`
   ```
   Create Bucket: cnpg-backups
   Enable: Versioning (recommended)
   Enable: Object Locking (optional, for immutability)
   ```

4. **Create Access Keys**
   ```
   Access Keys > Create access key
   Save both Access Key and Secret Key
   ```

### Step 2: Store Credentials in 1Password

Create entry `truenas_minio`:
| Field | Value |
|-------|-------|
| `access_key` | Your MinIO access key |
| `secret_key` | Your MinIO secret key |

### Step 3: Handle TLS Certificate

If using self-signed certificates, export the CA:

```bash
# On TrueNAS, find the certificate
# Or extract from browser when accessing MinIO

# Create secret with CA certificate
kubectl create secret generic truenas-ca-cert \
  --from-file=ca.crt=/path/to/truenas-ca.crt \
  -n freshrss
```

Alternatively, for testing, you can disable TLS verification (not recommended for production):
```yaml
# In ObjectStore spec
configuration:
  endpointURL: http://192.168.20.106:9000  # Use HTTP
```

### Step 4: Deploy Database with MinIO Backup

```bash
kubectl apply -f freshrss-database-minio.yaml
```

### Verify Backups

```bash
# Check backup status
kubectl get backups -n freshrss

# Check WAL archiving
kubectl logs -n freshrss freshrss-prod-cluster-1 -c postgres | grep -i wal

# List backups in MinIO
# Using mc (MinIO client)
mc alias set truenas https://192.168.20.106:9000 ACCESS_KEY SECRET_KEY
mc ls truenas/cnpg-backups/freshrss/
```

---

## Option 2: Kubernetes Volume Snapshots

### Prerequisites

1. **Verify Democratic CSI Snapshot Support**
   
   Check if your CSI driver supports snapshots:
   ```bash
   kubectl get csidrivers freenas-api-iscsi -o yaml | grep -A5 capabilities
   ```

2. **Install Snapshot Controller** (if not present)
   ```bash
   # Check if snapshot CRDs exist
   kubectl get crd volumesnapshots.snapshot.storage.k8s.io
   
   # If not, install snapshot controller
   kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
   kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
   kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
   ```

### Step 1: Create VolumeSnapshotClass

The VolumeSnapshotClass tells Kubernetes how to create snapshots with your CSI driver:

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: democratic-csi-iscsi-snapclass
driver: freenas-api-iscsi  # Must match your CSI driver name
deletionPolicy: Delete      # or Retain
parameters:
  detachedSnapshots: "false"
```

### Step 2: Deploy Database with Volume Snapshot Backup

```bash
kubectl apply -f freshrss-database-volumesnapshot.yaml
```

### Step 3: Verify Snapshots

```bash
# List volume snapshots
kubectl get volumesnapshots -n freshrss

# Check snapshot content
kubectl get volumesnapshotcontents

# Verify on TrueNAS
# Navigate to Storage > Snapshots to see ZFS snapshots
```

### Manual Snapshot

```bash
kubectl apply -f - <<EOF
apiVersion: postgresql.cnpg.io/v1
kind: Backup
metadata:
  name: freshrss-manual-$(date +%Y%m%d-%H%M%S)
  namespace: freshrss
spec:
  cluster:
    name: freshrss-prod-cluster
  method: volumeSnapshot
EOF
```

---

## Recovery Procedures

### Restore from MinIO Backup

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: freshrss-restored
  namespace: freshrss
spec:
  instances: 3
  
  bootstrap:
    recovery:
      source: freshrss-prod-cluster
      # Optional: Point-in-time recovery
      # recoveryTarget:
      #   targetTime: "2025-02-05T10:00:00Z"
  
  externalClusters:
  - name: freshrss-prod-cluster
    plugin:
      name: barman-cloud.cloudnative-pg.io
      parameters:
        barmanObjectName: freshrss-prod-backup
```

### Restore from Volume Snapshot

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: freshrss-restored
  namespace: freshrss
spec:
  instances: 3
  
  bootstrap:
    recovery:
      volumeSnapshots:
        storage:
          name: freshrss-prod-cluster-1-20250205020000  # Snapshot name
          kind: VolumeSnapshot
          apiGroup: snapshot.storage.k8s.io
        walStorage:
          name: freshrss-prod-cluster-1-wal-20250205020000
          kind: VolumeSnapshot
          apiGroup: snapshot.storage.k8s.io
```

---

## Snapshot Retention Management

### For MinIO Backups

Retention is handled by Barman Cloud via the `retentionPolicy` setting:
```yaml
retentionPolicy: "7d"  # Keep 7 days
# or
retentionPolicy: "4w"  # Keep 4 weeks
```

### For Volume Snapshots

Create a cleanup CronJob or use TrueNAS snapshot retention:

**Option A: TrueNAS Periodic Snapshot Task**
```
Data Protection > Periodic Snapshot Tasks > Add
Dataset: home-share/iscsi/k8s/prod/volumes
Recursive: Yes
Snapshot Lifetime: 7 days
```

**Option B: Kubernetes CronJob**
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cleanup-old-snapshots
  namespace: freshrss
spec:
  schedule: "0 3 * * *"  # Daily at 3 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleanup
            image: bitnami/kubectl:latest
            command:
            - /bin/sh
            - -c
            - |
              # Delete snapshots older than 7 days
              kubectl get volumesnapshots -n freshrss -o json | \
                jq -r '.items[] | select(.metadata.creationTimestamp | fromdateiso8601 < (now - 604800)) | .metadata.name' | \
                xargs -r kubectl delete volumesnapshot -n freshrss
          restartPolicy: OnFailure
          serviceAccountName: snapshot-cleanup-sa
```

---

## Monitoring Backup Health

Add these to your monitoring stack:

```yaml
# PrometheusRule for backup alerts
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: cnpg-backup-alerts
  namespace: monitoring
spec:
  groups:
  - name: cnpg-backups
    rules:
    - alert: CNPGBackupFailed
      expr: cnpg_pg_backup_last_status{status="failed"} == 1
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "CloudNativePG backup failed"
        
    - alert: CNPGBackupStale
      expr: time() - cnpg_pg_backup_last_success_timestamp > 86400
      for: 1h
      labels:
        severity: warning
      annotations:
        summary: "No successful backup in 24 hours"
```

---

## TrueNAS Dataset Structure

Recommended structure for organizing backups:

```
home-share/
├── iscsi/
│   └── k8s/
│       ├── prod/
│       │   ├── volumes/      # Database PVCs
│       │   └── snapshots/    # Detached snapshots
│       └── dev/
│           ├── volumes/
│           └── snapshots/
└── apps/
    └── minio/
        └── data/             # MinIO object storage
            └── cnpg-backups/ # Backup bucket
```
