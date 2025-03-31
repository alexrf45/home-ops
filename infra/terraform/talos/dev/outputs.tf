output "schematic_id" {
  value = module.dev.schematic_id
}

output "installer_image_iso" {
  value = module.dev.installer_image_iso
}

output "installer_disk_image" {
  value = module.dev.installer_disk_image
}

output "client_configuration" {
  value     = module.dev.client_configuration
  sensitive = true
}

output "kube_config" {
  value     = module.dev.kube_config
  sensitive = true
}
output "machine_config" {
  value     = module.dev.machine_config
  sensitive = true
}
