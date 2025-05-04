data "talos_image_factory_extensions_versions" "worker" {
  # get the latest talos version
  talos_version = var.cluster.talos_version
  filters = {
    names = var.cluster.worker_extensions
  }
}

data "talos_image_factory_urls" "worker" {
  talos_version = var.cluster.talos_version
  schematic_id  = talos_image_factory_schematic.worker.id
  platform      = var.cluster.platform
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


