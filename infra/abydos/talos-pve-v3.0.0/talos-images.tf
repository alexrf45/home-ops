# talos-images.tf - Talos Image Factory resources

#------------------------------------------------------------------------------
# Control Plane Image
#------------------------------------------------------------------------------
data "talos_image_factory_extensions_versions" "controlplane" {
  talos_version = var.cluster.talos_version
  filters = {
    names = var.cluster.control_plane_extensions
  }
}

resource "talos_image_factory_schematic" "controlplane" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.controlplane.extensions_info.*.name
      }
    }
  })
}

data "talos_image_factory_urls" "controlplane" {
  talos_version = var.cluster.talos_version
  schematic_id  = talos_image_factory_schematic.controlplane.id
  platform      = var.cluster.platform
}

#------------------------------------------------------------------------------
# Worker Image
#------------------------------------------------------------------------------
data "talos_image_factory_extensions_versions" "worker" {
  talos_version = var.cluster.talos_version
  filters = {
    names = var.cluster.worker_extensions
  }
}

resource "talos_image_factory_schematic" "worker" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.worker.extensions_info.*.name
      }
    }
  })
}

data "talos_image_factory_urls" "worker" {
  talos_version = var.cluster.talos_version
  schematic_id  = talos_image_factory_schematic.worker.id
  platform      = var.cluster.platform
}
