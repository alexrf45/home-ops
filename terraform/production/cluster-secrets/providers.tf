provider "aws" {}

provider "kubernetes" {
  config_path = "../terraform/configs/kubeconfig"
}

