# versions.tf - Provider requirements and configuration
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.93.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.10.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
  }

  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket         = "terraform-state"
  #   key            = "talos-cluster/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}


