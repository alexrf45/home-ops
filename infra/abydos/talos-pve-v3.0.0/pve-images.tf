#pve-images.tf - talos image download
resource "proxmox_virtual_environment_download_file" "talos_control_plane_image" {
  count                   = length(var.pve.hosts)
  content_type            = "iso"
  datastore_id            = var.pve.iso_datastore
  node_name               = var.pve.hosts[count.index]
  url                     = data.talos_image_factory_urls.controlplane.urls.disk_image
  decompression_algorithm = "zst"
  file_name               = "${var.env}-control-plane-talos.img"
  overwrite               = false
  upload_timeout          = 1800
}

resource "proxmox_virtual_environment_download_file" "talos_worker_image" {
  count                   = length(var.pve.hosts)
  content_type            = "iso"
  datastore_id            = var.pve.iso_datastore
  node_name               = var.pve.hosts[count.index]
  url                     = data.talos_image_factory_urls.worker.urls.disk_image
  decompression_algorithm = "zst"
  file_name               = "${var.env}-worker-talos.img"
  overwrite               = false
  upload_timeout          = 1800
}
