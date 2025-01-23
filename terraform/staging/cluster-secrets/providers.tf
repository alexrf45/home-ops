provider "aws" {

}

provider "kubernetes" {
  config_path = "../outputs/kubeconfig"
}

