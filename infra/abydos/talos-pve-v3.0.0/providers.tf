terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.93.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.9.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11.0"
    }
  }
  # backend "s3" {
  #
  # }
}

