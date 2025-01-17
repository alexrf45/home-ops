module "dev-test" {
  source       = "./module-testing/"
  github_owner = var.github_owner
  github_pat   = var.github_pat
  github_repository = {
    name        = "home-ops-flux"
    description = "Flux git repo for cluster"
    visibility  = "private"
  }
  pve_nodes = ["anubis", "cairo", "bastet", "horus"]
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
        install_image = "${module.dev-test.schematic_id}"
        datastore_id  = "data"
        node          = "cairo"
        memory        = 8092
        size          = 50
        storage       = 150
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
        install_image = "${module.dev-test.schematic_id}"
        datastore_id  = "data"
        node          = "anubis"
        memory        = 8092
        size          = 50
        storage       = 150
      },
      "10.3.3.62" = {
        install_disk  = "/dev/vda"
        install_image = "${module.dev-test.schematic_id}"
        datastore_id  = "data"
        node          = "anubis"
        memory        = 8092
        size          = 50
        storage       = 150
      }
    }
  }
}
