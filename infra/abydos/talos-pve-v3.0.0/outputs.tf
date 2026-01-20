# outputs.tf - Comprehensive outputs for integration

output "kubeconfig" {
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
  description = "Raw kubeconfig for cluster access"
}

output "kubeconfig_host" {
  value       = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
  description = "Kubernetes API server host"
}

output "talos_config" {
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
  description = "Talos client configuration (talosconfig)"
}

output "kubernetes_client_configuration" {
  value       = talos_cluster_kubeconfig.this.kubernetes_client_configuration
  sensitive   = true
  description = "Kubernetes client configuration object"
}

#------------------------------------------------------------------------------
# Control Plane Information
#------------------------------------------------------------------------------
output "controlplane_nodes" {
  value = {
    for k, v in var.controlplane_nodes : k => {
      vm_id        = proxmox_virtual_environment_vm.controlplane[k].vm_id
      hostname     = proxmox_virtual_environment_vm.controlplane[k].name
      ip           = v.ip
      proxmox_host = v.proxmox_host
    }
  }
  description = "Control plane node information"
}

output "controlplane_ips" {
  value       = local.controlplane_ips
  description = "List of control plane IP addresses"
}

output "cluster_endpoint" {
  value       = var.cluster.endpoint
  description = "Cluster API endpoint IP"
}

output "cluster_vip" {
  value       = var.cluster.vip_ip
  description = "Cluster VIP address"
}

#------------------------------------------------------------------------------
# Worker Information (Key for Scaling)
#------------------------------------------------------------------------------
output "worker_nodes" {
  value = {
    for k, v in var.worker_nodes : k => {
      vm_id        = proxmox_virtual_environment_vm.worker[k].vm_id
      hostname     = proxmox_virtual_environment_vm.worker[k].name
      ip           = v.ip
      proxmox_host = v.proxmox_host
      labels       = v.node_labels
    }
  }
  description = "Worker node information"
}

output "worker_ips" {
  value       = local.worker_ips
  description = "List of worker IP addresses"
}

output "worker_count" {
  value       = length(var.worker_nodes)
  description = "Current number of worker nodes"
}

#------------------------------------------------------------------------------
# Monitoring Integration
#------------------------------------------------------------------------------
output "monitoring_config" {
  value = {
    cluster_name     = var.cluster.name
    environment      = var.environment
    api_server_url   = "https://${var.cluster.endpoint}:6443"
    controlplane_ips = local.controlplane_ips
    worker_ips       = local.worker_ips
    all_node_ips     = local.all_node_ips
    service_cidr     = var.talos_config.service_subnets[0]
    pod_cidr         = var.talos_config.pod_subnets[0]
    cluster_dns      = var.talos_config.cluster_dns[0]
    cilium_namespace = var.cilium_config.namespace
    load_balancer_range = {
      start = local.cilium_lb_pool_start
      stop  = local.cilium_lb_pool_stop
    }
  }
  description = "Configuration values for monitoring stack deployment"
}

#------------------------------------------------------------------------------
# GitOps Integration
#------------------------------------------------------------------------------
output "cilium_manifests" {
  value       = var.deploy_cilium ? null : try(data.helm_template.cilium[0].manifest, null)
  description = "Cilium manifests for GitOps deployment (only when deploy_cilium = false)"
}

output "flux_bootstrap_values" {
  value = {
    cluster_name    = var.cluster.name
    cluster_path    = "clusters/${var.cluster.name}"
    sops_age_key    = "flux-${var.environment}.agekey"
    api_server_host = var.cluster.endpoint
  }
  description = "Values for Flux bootstrap script"
}

#------------------------------------------------------------------------------
# Encryption (Sensitive)
#------------------------------------------------------------------------------
output "encryption_key" {
  value = var.encryption.enabled && !var.encryption.tpm_based ? (
    var.encryption.static_key != "" ? var.encryption.static_key : try(random_password.encryption_key[0].result, null)
  ) : null
  sensitive   = true
  description = "Disk encryption key (store this securely!) - only for non-TPM encryption"
}

#------------------------------------------------------------------------------
# Image Information
#------------------------------------------------------------------------------
output "talos_images" {
  value = {
    controlplane = {
      schematic_id = talos_image_factory_schematic.controlplane.id
      image_url    = data.talos_image_factory_urls.controlplane.urls.disk_image
    }
    worker = {
      schematic_id = talos_image_factory_schematic.worker.id
      image_url    = data.talos_image_factory_urls.worker.urls.disk_image
    }
  }
  description = "Talos image factory information"
}

#------------------------------------------------------------------------------
# Next Steps / Instructions
#------------------------------------------------------------------------------
output "post_deployment_instructions" {
  value       = <<-EOT
    
    ============================================================
    Cluster "${var.cluster.name}" Deployment Complete!
    ============================================================
    
    1. Save kubeconfig:
       terraform output -raw kubeconfig > ~/.kube/${var.environment}
    
    2. Save talosconfig:
       terraform output -raw talos_config > ~/.talos/${var.environment}
    
    3. Verify cluster:
       kubectl --kubeconfig ~/.kube/${var.environment} get nodes
    
    4. For day-2 operations, set bootstrap_cluster = false:
       This prevents bootstrap failures on subsequent applies.
    
    5. To add workers, simply add entries to worker_nodes variable
       and run: terraform apply
    
    Control Plane IPs: ${join(", ", local.controlplane_ips)}
    Worker IPs: ${join(", ", local.worker_ips)}
    API Endpoint: https://${var.cluster.endpoint}:6443
    
    ============================================================
  EOT
  description = "Post-deployment instructions"
}
