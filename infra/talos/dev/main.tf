module "dev" {
  source    = "git@github.com:alexrf45/lab.git//talos-pve-v1.3.3?ref=v1.4.1"
  pve_nodes = ["home-0", "home-1", "home-2", "home-3", "home-4", "home-5"]
  cluster = {
    name           = "dev"
    env            = "dev"
    endpoint       = "10.3.3.70"
    pve_endpoint   = "10.3.3.2"
    vip_ip         = "10.3.3.69"
    gateway        = "10.3.3.1"
    talos_version  = "v1.10.5"
    cilium_version = "v1.17.5"
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
      node             = "home-0"
      vm_id            = 1000
      datastore_id     = "local-lvm"
      storage_id       = "data"
      allow_scheduling = false
      ip               = "10.3.3.70"
      cores            = 2
      memory           = 8092
      size             = 20
      storage_size     = 100

    },
    v2 = {
      install_disk     = "/dev/vda"
      machine_type     = "controlplane"
      node             = "home-1"
      vm_id            = 1001
      datastore_id     = "local-lvm"
      storage_id       = "data"
      allow_scheduling = false
      ip               = "10.3.3.71"
      cores            = 2
      memory           = 8092
      size             = 25
      storage_size     = 200
    },
    v3 = {
      install_disk     = "/dev/vda"
      machine_type     = "controlplane"
      node             = "home-2"
      vm_id            = 1002
      datastore_id     = "local-lvm"
      storage_id       = "data"
      allow_scheduling = false
      ip               = "10.3.3.72"
      cores            = 2
      memory           = 8092
      size             = 25
      storage_size     = 200
    },
    v4 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-3"
      vm_id        = 1003
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.73"
      cores        = 2
      memory       = 8092
      size         = 25
      storage_size = 200
    },

    v5 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-4"
      vm_id        = 1004
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.74"
      cores        = 2
      memory       = 8092
      size         = 25
      storage_size = 200
    },

    v6 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-5"
      vm_id        = 1005
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.75"
      cores        = 2
      memory       = 8092
      size         = 25
      storage_size = 200
    },
  }
}
