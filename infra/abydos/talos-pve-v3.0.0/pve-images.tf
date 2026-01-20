# pve-images.tf - Proxmox image downloads

resource "proxmox_virtual_environment_download_file" "talos_controlplane_image" {
  count = length(var.pve_hosts.hosts)

  content_type            = "iso"
  datastore_id            = var.pve_hosts.iso_datastore
  node_name               = var.pve_hosts.hosts[count.index]
  url                     = data.talos_image_factory_urls.controlplane.urls.disk_image
  decompression_algorithm = "zst"
  file_name               = "${var.environment}-controlplane-talos-${var.cluster.talos_version}.img"
  overwrite               = false
  upload_timeout          = 3600
}

resource "proxmox_virtual_environment_download_file" "talos_worker_image" {
  count = length(var.pve_hosts.hosts)

  content_type            = "iso"
  datastore_id            = var.pve_hosts.iso_datastore
  node_name               = var.pve_hosts.hosts[count.index]
  url                     = data.talos_image_factory_urls.worker.urls.disk_image
  decompression_algorithm = "zst"
  file_name               = "${var.environment}-worker-talos-${var.cluster.talos_version}.img"
  overwrite               = false
  upload_timeout          = 3600
}
