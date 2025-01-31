output "schematic_id" {
  value = talos_image_factory_schematic.this.id
}

output "installer_image_iso" {
  value = data.talos_image_factory_urls.this.urls.iso
}

output "installer_disk_image" {
  value = data.talos_image_factory_urls.this.urls.disk_image
}


output "client_configuration" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kube_config" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "machine_config" {
  value     = data.talos_machine_configuration.this["v1"].machine_configuration
  sensitive = true
}

output "pve_token" {
  value     = proxmox_virtual_environment_user_token.user_token.value
  sensitive = true
}
