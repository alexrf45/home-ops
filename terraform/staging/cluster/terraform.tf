terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.72.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.7.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
  backend "s3" {

  }
}


