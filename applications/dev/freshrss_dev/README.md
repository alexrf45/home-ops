# FreshRSS Kubernetes Deployment

This deployment uses the official FreshRSS Docker image with CloudNativePG PostgreSQL database, following the same patterns as the Wallabag deployment.

## Prerequisites

### 1Password Secrets

Create the following entries in 1Password:

#### `freshrss_prod_db` (Database Credentials for CloudNativePG)
| Field | Description | Example |
|-------|-------------|---------|
| `username` | PostgreSQL username | `freshrss` |
| `password` | PostgreSQL password | `<secure-password>` |

#### `freshrss_prod` (Application Credentials)
| Field | Description | Example |
|-------|-------------|---------|
| `db_user` | Database username | `freshrss` |
| `db_password` | Database password | `<same-as-above>` |
| `db_name` | Database name | `freshrss` |
| `db_host` | Database host (CloudNativePG service) | `freshrss-prod-cluster-rw.freshrss.svc.cluster.local` |
| `db_port` | Database port | `5432` |
| `admin_user` | FreshRSS admin username | `admin` |
| `admin_password` | FreshRSS admin password | `<secure-password>` |
| `admin_email` | Admin email address | `admin@example.com` |
| `admin_api_password` | API password for mobile apps | `<secure-password>` |
| `base_url` | Public URL of FreshRSS | `https://freshrss.home-0ps.com` |

## File Structure

```
freshrss/
├── kustomization.yaml          # Kustomize configuration
├── namespace.yaml              # Namespace definition
├── freshrss-configmap.yaml     # Non-sensitive configuration
├── freshrss-external-secret.yaml # App credentials from 1Password
├── freshrss-db-secret.yaml     # DB credentials from 1Password
├── freshrss-database.yaml      # CloudNativePG PostgreSQL cluster
└── freshrss-app.yaml           # Deployment, PVCs, Service, HTTPRoute
```

## Configuration Details

### Environment Variables (ConfigMap)

| Variable | Value | Description |
|----------|-------|-------------|
| `TZ` | `America/New_York` | Timezone for feed refresh |
| `CRON_MIN` | `3,18,33,48` | Refresh feeds every 15 minutes |
| `FRESHRSS_ENV` | `production` | Production mode |
| `COPY_LOG_TO_SYSLOG` | `On` | Enable syslog |
| `COPY_SYSLOG_TO_STDERR` | `On` | Output logs to stderr |
| `DB_TYPE` | `pgsql` | PostgreSQL database type |

### Database Configuration

The CloudNativePG cluster is configured with:
- **3 instances** for high availability
- **10Gi storage** for data
- **5Gi storage** for WAL
- **Daily backups** via Barman plugin
- **scram-sha-256** authentication
- SSL connections from pod network (10.43.0.0/16)

### Storage

- **Data PVC**: 5Gi for FreshRSS configuration and SQLite cache
- **Extensions PVC**: 1Gi for third-party extensions

## Deployment

```bash
# Apply with kubectl
kubectl apply -k applications/prod/freshrss/

# Or let Flux handle it via GitOps
```

## Post-Deployment

1. Access FreshRSS at your configured URL
2. The auto-install parameters will configure the database and create the admin user on first run
3. Configure mobile apps using the API password

## Mobile App Configuration

FreshRSS supports the Google Reader API. Configure your mobile app with:
- **Server URL**: `https://freshrss.home-0ps.com/api/greader.php`
- **Username**: Your admin username
- **Password**: Your API password

Recommended apps:
- **Android**: Readrops, FeedMe, Read You
- **iOS**: Reeder Classic, lire
- **Desktop**: Fluent Reader, NewsFlash
