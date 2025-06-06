output "schematic_id" {
  value = module.dev-test.schematic_id
}

output "installer_image_iso" {
  value = module.dev-test.installer_image_iso
}

output "installer_disk_image" {
  value = module.dev-test.installer_disk_image
}

output "client_configuration" {
  value     = module.dev-test.client_configuration
  sensitive = true
}

output "kube_config" {
  value     = module.dev-test.kube_config
  sensitive = true
}

output "machine_config" {
  value     = module.dev-test.machine_config
  sensitive = true
}

