module "dev" {
  source    = "./module"
  pve_nodes = ["home-3", "home-4"]
  cluster = {
    name          = "dev"
    env           = "dev"
    endpoint      = "10.3.3.70"
    pve_endpoint  = "10.3.3.2"
    vip_ip        = "10.3.3.69"
    gateway       = "10.3.3.1"
    talos_version = "v1.10.0"
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
      node             = "home-3"
      vm_id            = 1000
      datastore_id     = "local-lvm"
      storage_id       = "data"
      allow_scheduling = true
      ip               = "10.3.3.70"
      cores            = 2
      memory           = 8092
      size             = 20
      storage_size     = 100

    },
    v2 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-4"
      vm_id        = 1001
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.71"
      cores        = 2
      memory       = 8092
      size         = 25
      storage_size = 200
    },
    v3 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-4"
      vm_id        = 1002
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.72"
      cores        = 2
      memory       = 8092
      size         = 25
      storage_size = 200
    },
  }
}
