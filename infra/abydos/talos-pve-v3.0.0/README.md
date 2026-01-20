# Talos Linux on Proxmox - Terraform Module v3.0.0

A Terraform module for deploying Talos Linux Kubernetes clusters on Proxmox VE with **independent worker node scaling**.

## Key Features

- **Independent Worker Scaling**: Add or remove worker nodes without affecting control plane
- **Protected Control Plane**: `prevent_destroy` lifecycle prevents accidental deletion
- **Conditional Bootstrap**: Set `bootstrap_cluster = false` after initial deployment
- **Optional Cilium**: Deploy via Terraform or GitOps (Flux)
- **Comprehensive Outputs**: Ready for monitoring and GitOps integration

## Quick Start

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
vim terraform.tfvars

# Initialize and apply
terraform init
terraform plan
terraform apply

# Save credentials
terraform output -raw kubeconfig > ~/.kube/prod
terraform output -raw talos_config > ~/.talos/prod

# IMPORTANT: After successful deployment, set bootstrap_cluster = false
# This prevents bootstrap failures on subsequent applies
```

## Adding Workers (Day 2 Operations)

Simply add a new entry to `worker_nodes` and apply:

```hcl
worker_nodes = {
  # ... existing workers ...
  
  "wk-new" = {
    proxmox_host       = "home-6"
    ip                 = "10.3.3.130"
    cores              = 4
    memory             = 16384
    storage_id         = "data"
    storage_disk_count = 2
    node_labels = {
      "node.kubernetes.io/workload" = "database"
    }
  }
}
```

```bash
terraform plan   # Shows only new worker being created
terraform apply  # Control plane and existing workers unchanged
```

## Removing Workers

Remove the entry from `worker_nodes` and apply:

```bash
terraform plan   # Shows only that worker being destroyed
terraform apply  # Other nodes unchanged
```

## Migration from v2.0.0

### Step 1: Backup State

```bash
terraform state pull > backup.tfstate
cp terraform.tfvars terraform.tfvars.bak
```

### Step 2: Update Variables

The main changes:
- `nodes` map split into `controlplane_nodes` and `worker_nodes`
- `pve_config` renamed to `pve_hosts`
- New `bootstrap_cluster` variable (set to `false` for existing clusters)
- New `deploy_cilium` variable

```hcl
# OLD (v2.0.0)
nodes = {
  "1" = { machine_type = "controlplane", ... }
  "4" = { machine_type = "worker", ... }
}

# NEW (v3.0.0)
controlplane_nodes = {
  "cp-1" = { ... }  # No machine_type needed
}
worker_nodes = {
  "wk-1" = { ... }  # No machine_type needed
}
```

### Step 3: Move State (Critical!)

```bash
# Move control plane VM state
terraform state mv \
  'proxmox_virtual_environment_vm.talos_vm["1"]' \
  'proxmox_virtual_environment_vm.controlplane["cp-1"]'

# Move worker VM state  
terraform state mv \
  'proxmox_virtual_environment_vm.talos_vm["4"]' \
  'proxmox_virtual_environment_vm.worker["wk-1"]'

# Move random IDs
terraform state mv \
  'random_id.example["1"]' \
  'random_id.controlplane["cp-1"]'

terraform state mv \
  'random_id.example["4"]' \
  'random_id.worker["wk-1"]'

# Move Talos configuration apply resources
terraform state mv \
  'talos_machine_configuration_apply.this["1"]' \
  'talos_machine_configuration_apply.controlplane["cp-1"]'

terraform state mv \
  'talos_machine_configuration_apply.this["4"]' \
  'talos_machine_configuration_apply.worker["wk-1"]'
```

### Step 4: Set Bootstrap to False

Since your cluster is already running:

```hcl
bootstrap_cluster = false  # Prevents re-bootstrap attempts
```

### Step 5: Plan and Verify

```bash
terraform plan
# Should show minimal or no changes for existing resources
# May show changes to lifecycle/tags which are safe
```

## File Structure

```
talos-pve-v3.0.0/
├── versions.tf              # Provider requirements
├── variables.tf             # All variable definitions
├── locals.tf                # Computed values
├── outputs.tf               # All outputs
├── talos-images.tf          # Image factory resources
├── talos-secrets.tf         # Machine secrets
├── talos-config.tf          # Machine configuration
├── talos-bootstrap.tf       # Cluster bootstrap
├── pve-images.tf            # Proxmox image downloads
├── pve-controlplane.tf      # Control plane VMs (protected)
├── pve-workers.tf           # Worker VMs (scalable)
├── cilium.tf                # Optional CNI deployment
└── terraform.tfvars.example # Example configuration
```

## Variables Reference

### Required Variables

| Variable | Description |
|----------|-------------|
| `environment` | Environment name (dev, test, prod) |
| `pve_hosts` | Proxmox VE configuration |
| `cluster` | Cluster configuration (name, endpoint, etc.) |
| `controlplane_nodes` | Control plane node definitions |
| `cilium_config` | Cilium CNI configuration |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `worker_nodes` | `{}` | Worker node definitions |
| `bootstrap_cluster` | `true` | Bootstrap on first apply |
| `deploy_cilium` | `true` | Deploy Cilium via Terraform |
| `encryption` | disabled | Disk encryption config |
| `talos_config` | defaults | Advanced Talos settings |
| `security_config` | defaults | Security settings |

## Outputs Reference

| Output | Description |
|--------|-------------|
| `kubeconfig` | Raw kubeconfig (sensitive) |
| `talos_config` | Talos client config (sensitive) |
| `controlplane_nodes` | Control plane details |
| `worker_nodes` | Worker node details |
| `monitoring_config` | Values for monitoring setup |
| `cilium_manifests` | Cilium manifests for GitOps |

## GitOps Integration

To use Flux for Cilium management instead of Terraform:

```hcl
deploy_cilium = false
```

Then use the `cilium_manifests` output or configure Flux HelmRelease.

## Troubleshooting

### "Cluster already bootstrapped" Error

Set `bootstrap_cluster = false` in your tfvars.

### Workers Not Joining

1. Verify control plane is healthy: `talosctl health`
2. Check worker can reach API: `ping 10.3.3.120`
3. Check Talos config applied: `talosctl -n <worker-ip> get members`

### Want to Force Recreate a Worker

```bash
terraform taint 'proxmox_virtual_environment_vm.worker["wk-1"]'
terraform apply
```

### Control Plane Protected from Destroy

This is intentional. To actually destroy control plane (dangerous!):
1. Comment out `prevent_destroy = true` in pve-controlplane.tf
2. Run `terraform apply` then `terraform destroy`

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| proxmox | ~> 0.80.0 |
| talos | ~> 0.9.0 |
| helm | ~> 3.0.0 |
| kubectl | ~> 1.14 |
