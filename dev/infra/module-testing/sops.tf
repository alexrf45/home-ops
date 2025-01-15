data "sops_file" "this" {
  source_file = var.patch
}

output "patch" {
  value = data.sops_file.raw
}
