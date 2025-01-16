terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.69.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.7.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.4.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
  backend "s3" {

  }
}

provider "talos" {
}

provider "proxmox" {
  endpoint = "https://10.3.3.9:8006"
  username = "root@pam"
  password = var.password
  insecure = true
  ssh {
    agent = false
  }
}
provider "flux" {
  kubernetes = {
    config_path = "${path.root}/configs/kubeconfig"
  }
  git = {
    url = "https://github.com/${var.github_owner}/${var.github_repository.name}.git"
    http = {
      username = "fr3d" # This can be any string when using a personal access token
      password = var.github_pat
    }
  }
}

provider "github" {
  owner = var.github_owner
  token = var.github_pat
}

provider "helm" {
  kubernetes {
    config_path = "${path.root}/configs/kubeconfig"
  }
}

module "dev-test" {
  source       = "./module-testing/"
  github_owner = var.github_owner
  github_pat   = var.github_pat
  github_repository = {
    name        = "home-ops-flux"
    description = "Flux git repo for ${module.dev-test.name} cluster" #TODO: fix module path
    visibility  = "private"
  }
  pve_nodes = ["anubis", "cairo"]
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
