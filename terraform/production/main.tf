module "prod" {
  source    = "./module2"
  pve_nodes = ["home-0", "home-1", "home-2", "home-3", "home-4"]
  cluster = {
    name          = "prod"
    env           = "prod"
    endpoint      = "10.3.3.60"
    pve_endpoint  = "10.3.3.2"
    vip_ip        = "10.3.3.59"
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
      node             = "home-1"
      vm_id            = 2000
      datastore_id     = "local-lvm"
      storage_id       = "data"
      allow_scheduling = false
      ip               = "10.3.3.60"
      cores            = 2
      memory           = 8092
      size             = 25
      storage_size     = 50

    },
    v2 = {
      install_disk     = "/dev/vda"
      machine_type     = "controlplane"
      node             = "home-0"
      vm_id            = 2001
      datastore_id     = "local-lvm"
      storage_id       = "data"
      allow_scheduling = true
      ip               = "10.3.3.61"
      cores            = 2
      memory           = 8092
      size             = 50
      storage_size     = 150
    },
    v3 = {
      install_disk     = "/dev/vda"
      machine_type     = "controlplane"
      node             = "home-3"
      vm_id            = 2002
      datastore_id     = "local-lvm"
      storage_id       = "data"
      allow_scheduling = true
      ip               = "10.3.3.62"
      cores            = 2
      memory           = 8092
      size             = 50
      storage_size     = 150
    },
    v4 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-3"
      vm_id        = 2003
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.63"
      cores        = 2
      memory       = 8092
      size         = 50
      storage_size = 200

    },
    v5 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-4"
      vm_id        = 2004
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.64"
      cores        = 2
      memory       = 8092
      size         = 50
      storage_size = 150
    },
    v6 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-1"
      vm_id        = 2005
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.65"
      cores        = 2
      memory       = 8092
      size         = 50
      storage_size = 300
    },
    v7 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-2"
      vm_id        = 2006
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.66"
      cores        = 2
      memory       = 8092
      size         = 50
      storage_size = 200
    },
  }
}
