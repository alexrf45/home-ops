output "schematic_id" {
  value = talos_image_factory_schematic.this.id
}

output "installer_image_iso" {
  value = data.talos_image_factory_urls.this.urls.iso
}

output "installer_disk_image" {
  value = data.talos_image_factory_urls.this.urls.disk_image
}

output "controlplane_config" {
  value     = data.talos_machine_configuration.controlplane.machine_configuration
  sensitive = true
}
#
output "worker_config" {
  value     = data.talos_machine_configuration.worker.machine_configuration
  sensitive = true
}

output "client_configuration" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kube_config" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}


