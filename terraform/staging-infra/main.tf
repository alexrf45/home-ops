module "dev" {
  source            = "github.com/alexrf45/lab//talos-pve-flux?ref=rc-1"
  github_owner      = var.github_owner
  github_pat        = var.github_pat
  github_repository = var.github_repository
  flux_extras       = ["image-automation-controller", "image-reflector-controller"]
  pve_nodes         = ["cairo", "bastet", "osiris"]
  cluster = {
    name          = "fr3d"
    endpoint      = "10.3.3.60"
    gateway       = "10.3.3.1"
    talos_version = "v1.9.1"
    platform      = "nocloud"
    iso_datastore = "local"
  }
  node_data = {
    controlplanes = {
      "10.3.3.60" = {
        install_disk  = "/dev/vda"
        install_image = "${module.dev.schematic_id}"
        datastore_id  = "local-lvm"
        storage_id    = "data"
        node          = "cairo"
        memory        = 8092
        size          = 50
        storage       = 100
      },
      # "10.3.3.63" = {
      #   install_disk  = "/dev/vda"
      #   install_image = "${module.dev-test.schematic_id}"
      #   datastore_id  = "data"
      #   node          = "cario"
      #   memory        = 8092
      #   size          = 50
      #   storage       = 150
      # },
      # "10.3.3.64" = {
      #   install_disk  = "/dev/vda"
      #   install_image = "${module.dev-test.schematic_id}"
      #   datastore_id  = "data"
      #   node          = "anubis"
      #   memory        = 8092
      #   size          = 50
      #   storage       = 150
      # },
    }
    workers = {
      "10.3.3.61" = {
        install_disk  = "/dev/vda"
        install_image = "${module.dev.schematic_id}"
        datastore_id  = "local-lvm"
        storage_id    = "data"
        node          = "bastet"
        memory        = 8092
        size          = 50
        storage       = 100
      },
      "10.3.3.62" = {
        install_disk  = "/dev/vda"
        install_image = "${module.dev.schematic_id}"
        datastore_id  = "local-lvm"
        storage_id    = "data"
        node          = "osiris"
        memory        = 8092
        size          = 50
        storage       = 100
      }
    }
  }
}
