data "talos_image_factory_extensions_versions" "worker" {
  # get the latest talos version
  talos_version = var.talos_config.talos_version
  filters = {
    names = var.talos_config.worker_extensions
  }
}

data "talos_image_factory_urls" "worker" {
  talos_version = var.talos_config.talos_version
  schematic_id  = talos_image_factory_schematic.worker.id
  platform      = var.talos_config.platform
}


resource "talos_image_factory_schematic" "worker" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.worker.extensions_info.*.name
        }
      }
    }
  )
}



resource "proxmox_virtual_environment_download_file" "talos_worker_image" {
  count                   = length(var.pve_config.hosts)
  content_type            = "iso"
  datastore_id            = var.pve_config.iso_datastore
  node_name               = var.pve_config.hosts[count.index]
  url                     = data.talos_image_factory_urls.worker.urls.disk_image
  decompression_algorithm = "zst"
  file_name               = "${var.environment}-${random_id.that.id}-worker-talos.img"
  overwrite               = false
  upload_timeout          = 120
}
