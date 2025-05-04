module "dev" {
  source    = "./module"
  pve_nodes = ["home-dev"]
  cluster = {
    name          = "dev"
    env           = "dev"
    endpoint      = "10.3.3.100"
    pve_endpoint  = "10.3.3.55"
    vip_ip        = "10.3.3.99"
    gateway       = "10.3.3.1"
    talos_version = "v1.9.5"
    control_plane_extensions = [
      "intel-ucode",
      "glibc",
      "iscsi-tools",
      "util-linux-tools",
      "qemu-guest-agent",
      "i915",
      "tailscale"
    ]
    worker_extensions = [
      "intel-ucode",
      "glibc",
      "iscsi-tools",
      "util-linux-tools",
      "qemu-guest-agent",
      "i915"
    ]
    platform       = "nocloud"
    iso_datastore  = "local"
    tailscale_auth = var.auth_key
  }

  nodes = {
    v1 = {
      install_disk     = "/dev/vda"
      machine_type     = "controlplane"
      node             = "home-dev"
      vm_id            = 100
      datastore_id     = "local-lvm"
      storage_id       = "local-lvm"
      allow_scheduling = true
      ip               = "10.3.3.100"
      cores            = 2
      memory           = 8092
      size             = 20
      storage_size     = 50

    },
    v2 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-dev"
      vm_id        = 101
      datastore_id = "local-lvm"
      storage_id   = "local-lvm"
      ip           = "10.3.3.101"
      cores        = 2
      memory       = 8092
      size         = 25
      storage_size = 50
    },
    v3 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-dev"
      vm_id        = 102
      datastore_id = "local-lvm"
      storage_id   = "local-lvm"
      ip           = "10.3.3.102"
      cores        = 2
      memory       = 8092
      size         = 25
      storage_size = 50
    },
  }
}
