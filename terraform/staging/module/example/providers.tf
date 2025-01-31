provider "talos" {
}

provider "kubernetes" {
  config_path = "./configs/kubeconfig"
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
    config_path = "./configs/kubeconfig"
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
    config_path = "./configs/kubeconfig"
  }
}
