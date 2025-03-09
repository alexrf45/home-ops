data "talos_image_factory_extensions_versions" "this" {
  # get the latest talos version
  talos_version = var.cluster.talos_version
  filters = {
    names = var.cluster.extensions
  }
}

data "talos_image_factory_urls" "this" {
  talos_version = var.cluster.talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = var.cluster.platform
}


resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
      }
    }
  )
}


