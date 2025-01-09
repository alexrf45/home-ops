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
  }
  backend "s3" {

  }
}


provider "proxmox" {
  endpoint = "https://10.3.3.9:8006"
  username = "root@pam"
  password = var.password
  insecure = true
  ssh {
    agent = true
  }
}

module "dev" {
  source = "./dev/"
  cluster = {
    name          = "fr3d"
    endpoint      = "10.3.3.60"
    gateway       = "10.3.3.1"
    talos_version = "v1.9.0"
    platform      = "nocloud"
    iso_datastore = "local"
  }
  controlplanes = {
    "ctrl-01" = {
      host_node    = "cairo"
      machine_type = "controlplane"
      datastore_id = "data"
      memory       = 4096
      size         = 70
      ip           = "10.3.3.60"
      vm_id        = "7000"
    },
    "ctrl-02" = {
      host_node    = "bastet"
      machine_type = "controlplane"
      datastore_id = "data"
      memory       = 4096
      size         = 70
      ip           = "10.3.3.61"
      vm_id        = "7001"
    },
    "ctrl-03" = {
      host_node    = "osiris"
      machine_type = "controlplane"
      datastore_id = "data"
      memory       = 4096
      size         = 70
      ip           = "10.3.3.62"
      vm_id        = "7002"
    }
  }
  nodes = {
    "node-02" = {
      host_node    = "cairo"
      machine_type = "worker"
      datastore_id = "data"
      memory       = 8092
      size         = 200
      ip           = "10.3.3.63"
      vm_id        = "8002"
    },
    "node-03" = {
      host_node    = "cairo"
      machine_type = "worker"
      datastore_id = "data"
      memory       = 8092
      size         = 200
      ip           = "10.3.3.64"
      vm_id        = "8003"
    },
  }
  machine_config_patches = [
    <<EOT
machine:
  kubelet:
    nodeIP:
      validSubnets:
        - 10.3.3.0/24
    extraMounts:
      - destination: /var/lib/longhorn
        type: bind
        source: /var/lib/longhorn
        options:
          - rbind
          - rshared
          - rw
  disks:
    - device: /dev/sda # The name of the disk to use.
      partitions:
        - mountpoint: /var/lib/longhorn
  install:
    disk: /dev/sda
EOT
  ]
}

resource "local_file" "kubeconfig" {
  content         = module.dev.kube_config
  filename        = "./outputs/kubeconfig"
  file_permission = "0600"
}

resource "local_file" "talo_config" {
  content  = module.dev.client_configuration
  filename = "./outputs/talosconfig"
}
