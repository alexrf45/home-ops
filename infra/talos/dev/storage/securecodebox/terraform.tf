terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "2.1.2"
    }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "2.31.0"
    # }
  }
  backend "s3" {

  }
}
