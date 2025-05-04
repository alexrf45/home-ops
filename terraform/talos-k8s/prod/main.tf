module "prod" {
  source    = "./module"
  pve_nodes = ["home-0", "home-1", "home-2"]
  cluster = {
    name          = "prod"
    env           = "prod"
    endpoint      = "10.3.3.50"
    pve_endpoint  = "10.3.3.2"
    vip_ip        = "10.3.3.49"
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
      install_disk     = "/prod/vda"
      machine_type     = "controlplane"
      node             = "home-0"
      vm_id            = 200
      datastore_id     = "local-lvm"
      storage_id       = "data"
      allow_scheduling = false
      ip               = "10.3.3.50"
      cores            = 2
      memory           = 8092
      size             = 50
      storage_size     = 50

    },
    v2 = {
      install_disk     = "/prod/vda"
      machine_type     = "controlplane"
      allow_scheduling = true
      node             = "home-1"
      vm_id            = 201
      datastore_id     = "local-lvm"
      storage_id       = "data"
      ip               = "10.3.3.51"
      cores            = 2
      memory           = 8092
      size             = 50
      storage_size     = 250
    },
    v3 = {
      install_disk     = "/prod/vda"
      machine_type     = "controlplane"
      allow_scheduling = true
      node             = "home-2"
      vm_id            = 202
      datastore_id     = "local-lvm"
      storage_id       = "data"
      ip               = "10.3.3.52"
      cores            = 2
      memory           = 8092
      size             = 50
      storage_size     = 250
    },
    v4 = {
      install_disk = "/prod/vda"
      machine_type = "worker"
      node         = "home-2"
      vm_id        = 203
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.53"
      cores        = 2
      memory       = 8092
      size         = 50
      storage_size = 250
    },
    v5 = {
      install_disk = "/prod/vda"
      machine_type = "worker"
      node         = "home-2"
      vm_id        = 204
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.54"
      cores        = 2
      memory       = 8092
      size         = 50
      storage_size = 250
    },

  }
}
