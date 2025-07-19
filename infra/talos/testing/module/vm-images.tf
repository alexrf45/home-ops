# vm-images.tf
resource "proxmox_virtual_environment_download_file" "talos_control_plane_image" {
  count                   = length(var.pve_config.hosts)
  content_type            = "iso"
  datastore_id            = var.pve_config.iso_datastore
  node_name               = var.pve_config.hosts[count.index]
  url                     = data.talos_image_factory_urls.controlplane.urls.disk_image
  decompression_algorithm = "zst"
  file_name               = "${var.cluster.env}-${random_id.cluster.id}-control-plane-talos.img"
  overwrite               = false
  upload_timeout          = 240
}

resource "proxmox_virtual_environment_download_file" "talos_worker_image" {
  count                   = length(var.pve_config.hosts)
  content_type            = "iso"
  datastore_id            = var.pve_config.iso_datastore
  node_name               = var.pve_config.hosts[count.index]
  url                     = data.talos_image_factory_urls.worker.urls.disk_image
  decompression_algorithm = "zst"
  file_name               = "${var.cluster.env}-${random_id.cluster.id}-worker-talos.img"
  overwrite               = false
  upload_timeout          = 240
}
