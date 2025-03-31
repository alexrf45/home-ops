module "dev" {
  source    = "./module"
  pve_nodes = ["home-3", "home-4"]
  cluster = {
    name          = "dev"
    env           = "dev"
    endpoint      = "10.3.3.100"
    pve_endpoint  = "10.3.3.2"
    vip_ip        = "10.3.3.99"
    gateway       = "10.3.3.1"
    talos_version = "v1.9.5"
    extensions = [
      "intel-ucode",
      "glibc",
      "iscsi-tools",
      "util-linux-tools",
      "qemu-guest-agent",
      "i915",
    ]
    platform      = "nocloud"
    iso_datastore = "local"
  }

  nodes = {
    v1 = {
      install_disk     = "/dev/vda"
      machine_type     = "controlplane"
      node             = "home-3"
      vm_id            = 100
      datastore_id     = "local-lvm"
      storage_id       = "data"
      allow_scheduling = false
      ip               = "10.3.3.100"
      cores            = 2
      memory           = 8092
      size             = 20
      storage_size     = 30

    },
    v2 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-4"
      vm_id        = 101
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.101"
      cores        = 2
      memory       = 8092
      size         = 25
      storage_size = 250
    },
    v3 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-4"
      vm_id        = 102
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.102"
      cores        = 2
      memory       = 8092
      size         = 25
      storage_size = 250
    },
  }
}
