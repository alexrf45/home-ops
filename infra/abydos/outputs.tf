# outputs.tf - Comprehensive outputs for integration

output "kubeconfig" {
  value       = module.abydos.kubeconfig
  sensitive   = true
  description = "Raw kubeconfig for cluster access"
}

output "talos_config" {
  value       = module.abydos.talos_config
  sensitive   = true
  description = "Talos client configuration (talosconfig)"
}

output "machineconfig" {
  value     = module.abydos.machineconfig
  sensitive = true
}

output "post_deployment_instructions" {
  value       = <<-EOT
 
    ============================================================
    Cluster "${var.talos.name}" Deployment Complete!
    ============================================================
 
    1. Save kubeconfig:
       terraform output -raw kubeconfig > ~/.kube/${var.env}
 
    2. Save talosconfig:
       terraform output -raw talos_config > ~/.talos/${var.env}
 
    3. Verify cluster:
       kubectl --kubeconfig ~/.kube/${var.env} get nodes
 
    4. For day-2 operations, set bootstrap_cluster = false:
       This prevents bootstrap failures on subsequent applies.
 
    5. To add workers, simply add entries to worker_nodes variable
       and run: terraform apply
 
    ============================================================
  EOT
  description = "Post-deployment instructions"
}
