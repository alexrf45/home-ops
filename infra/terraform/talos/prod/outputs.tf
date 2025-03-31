output "schematic_id" {
  value = module.prod.schematic_id
}

output "installer_image_iso" {
  value = module.prod.installer_image_iso
}

output "installer_disk_image" {
  value = module.prod.installer_disk_image
}

output "client_configuration" {
  value     = module.prod.client_configuration
  sensitive = true
}

output "kube_config" {
  value     = module.prod.kube_config
  sensitive = true
}
output "machine_config" {
  value     = module.prod.machine_config
  sensitive = true
}
