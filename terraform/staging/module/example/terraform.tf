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
  # backend "s3" { #uncomment to use remote backend
  #
  # }
}

