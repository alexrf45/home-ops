data "talos_image_factory_extensions_versions" "controlplane" {
  # get the latest talos version
  talos_version = var.cluster.talos_version
  filters = {
    names = var.cluster.control_plane_extensions
  }
}

data "talos_image_factory_urls" "controlplane" {
  talos_version = var.cluster.talos_version
  schematic_id  = talos_image_factory_schematic.controlplane.id
  platform      = var.cluster.platform
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


