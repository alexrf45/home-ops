output "talos_config" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}


output "machineconfig" {
  value     = values(talos_machine_configuration_apply.controlplane)[0].machine_configuration
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
