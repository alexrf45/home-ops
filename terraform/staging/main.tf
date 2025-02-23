module "dev-test" {
  source = "./module"

  pve_nodes = ["home-0", "home-1", "home-2"]
  cluster = {
    name          = "staging"
    env           = "staging"
    endpoint      = "10.3.3.80"
    pve_endpoint  = "10.3.3.2"
    gateway       = "10.3.3.1"
    talos_version = "v1.9.1"
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
      vm_id            = 1000
      datastore_id     = "local-lvm"
      storage_id       = "data"
      allow_scheduling = true
      ip               = "10.3.3.80"
      cores            = 2
      memory           = 8092
      size             = 25
      storage_size     = 50

    },
    v2 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-1"
      vm_id        = 1001
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.81"
      cores        = 2
      memory       = 8092
      size         = 25
      storage_size = 50
    },
    v3 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-2"
      vm_id        = 1002
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.82"
      cores        = 2
      memory       = 8092
      size         = 25
      storage_size = 50
    },
  }
}
