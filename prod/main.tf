module "dev" {
  source       = "github.com/alexrf45/lab//talos-pve-flux?ref=v1.1.0"
  github_owner = var.github_owner
  github_pat   = var.github_pat
  github_repository = {
    name        = var.github_repository.name
    description = var.github_repository.description
    visibility  = var.github_repository.visibility
  }
  flux_extras = ["image-automation-controller"]
  pve_nodes   = ["bastet", "osiris", "horus"]
  cluster = {
    name          = "fr3d"
    endpoint      = "10.3.3.40"
    gateway       = "10.3.3.1"
    talos_version = "v1.9.1"
    platform      = "nocloud"
    iso_datastore = "local"
  }
  node_data = {
    controlplanes = {
      "10.3.3.40" = {
        install_disk  = "/dev/vda"
        install_image = "${module.dev.schematic_id}"
        datastore_id  = "data"
        node          = "cairo"
        memory        = 8092
        size          = 50
        storage       = 60
      },
      "10.3.3.41" = {
        install_disk  = "/dev/vda"
        install_image = "${module.dev-test.schematic_id}"
        datastore_id  = "data"
        node          = "osiris"
        memory        = 8092
        size          = 50
        storage       = 70
      },
      "10.3.3.42" = {
        install_disk  = "/dev/vda"
        install_image = "${module.dev-test.schematic_id}"
        datastore_id  = "data"
        node          = "horus"
        memory        = 8092
        size          = 50
        storage       = 70
      },
    }
    workers = {
      "10.3.3.43" = {
        install_disk  = "/dev/vda"
        install_image = "${module.dev.schematic_id}"
        datastore_id  = "data"
        node          = "horus"
        memory        = 8092
        size          = 50
        storage       = 150
      },
      "10.3.3.44" = {
        install_disk  = "/dev/vda"
        install_image = "${module.dev.schematic_id}"
        datastore_id  = "data"
        node          = "anubis"
        memory        = 8092
        size          = 50
        storage       = 150
      }
      "10.3.3.45" = {
        install_disk  = "/dev/vda"
        install_image = "${module.dev.schematic_id}"
        datastore_id  = "data"
        node          = "bastet"
        memory        = 8092
        size          = 50
        storage       = 150
      }
    }
  }
}
