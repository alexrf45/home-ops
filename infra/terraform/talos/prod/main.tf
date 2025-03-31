module "prod" {
  source    = "./module"
  pve_nodes = ["home-0", "home-1", "home-2", "home-3"]
  cluster = {
    name          = "prod"
    env           = "prod"
    endpoint      = "10.3.3.110"
    pve_endpoint  = "10.3.3.2"
    vip_ip        = "10.3.3.109"
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
      node             = "home-0"
      vm_id            = 103
      datastore_id     = "local-lvm"
      storage_id       = "data"
      allow_scheduling = false
      ip               = "10.3.3.110"
      cores            = 2
      memory           = 8092
      size             = 25
      storage_size     = 50

    },
    v2 = {
      install_disk     = "/dev/vda"
      machine_type     = "controlplane"
      node             = "home-1"
      vm_id            = 104
      datastore_id     = "local-lvm"
      storage_id       = "data"
      allow_scheduling = true
      ip               = "10.3.3.111"
      cores            = 2
      memory           = 8092
      size             = 50
      storage_size     = 300
    },
    v3 = {
      install_disk     = "/dev/vda"
      machine_type     = "controlplane"
      node             = "home-3"
      vm_id            = 105
      datastore_id     = "local-lvm"
      storage_id       = "data"
      allow_scheduling = true
      ip               = "10.3.3.112"
      cores            = 2
      memory           = 8092
      size             = 50
      storage_size     = 300
    },
    v4 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-2"
      vm_id        = 106
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.113"
      cores        = 2
      memory       = 8092
      size         = 50
      storage_size = 200

    },
    v5 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-2"
      vm_id        = 107
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.114"
      cores        = 2
      memory       = 8092
      size         = 50
      storage_size = 300
    },
    v6 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-0"
      vm_id        = 108
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.115"
      cores        = 2
      memory       = 8092
      size         = 50
      storage_size = 300
    },
    v7 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-1"
      vm_id        = 109
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.116"
      cores        = 2
      memory       = 8092
      size         = 50
      storage_size = 300
    },
  }
}
