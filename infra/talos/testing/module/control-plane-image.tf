data "talos_image_factory_extensions_versions" "controlplane" {
  # get the latest talos version
  talos_version = var.talos_config.talos_version
  filters = {
    names = var.talos_config.control_plane_extensions
  }
}

data "talos_image_factory_urls" "controlplane" {
  talos_version = var.talos_config.talos_version
  schematic_id  = talos_image_factory_schematic.controlplane.id
  platform      = var.talos_config.platform
}


resource "talos_image_factory_schematic" "controlplane" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.controlplane.extensions_info.*.name
        }
      }
    }
  )
}

resource "proxmox_virtual_environment_download_file" "talos_control_plane_image" {
  count                   = length(var.pve_config.hosts)
  content_type            = "iso"
  datastore_id            = var.pve_config.iso_datastore
  node_name               = var.pve_config.hosts[count.index]
  url                     = data.talos_image_factory_urls.controlplane.urls.disk_image
  decompression_algorithm = "zst"
  file_name               = "${var.environment}-${random_id.this.id}-control-plane-talos.img"
  overwrite               = false
  upload_timeout          = 240
}
