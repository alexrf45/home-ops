# outputs.tf - Comprehensive outputs for integration

output "kubeconfig" {
  value       = module.abydos.kubeconfig
  sensitive   = true
  description = "Raw kubeconfig for cluster access"
}

output "kubeconfig_host" {
  value       = module.abydos.kubeconfig_host
  description = "Kubernetes API server host"
}

output "talos_config" {
  value       = module.abydos.talos_config
  sensitive   = true
  description = "Talos client configuration (talosconfig)"
}

output "kubernetes_client_configuration" {
  value       = module.abydos.kubernetes_client_configuration
  sensitive   = true
  description = "Kubernetes client configuration object"
}

output "flux_bootstrap_values" {
  value = module.abydos.flux_bootstrap_values
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
 
    ============================================================
  EOT
  description = "Post-deployment instructions"
}
