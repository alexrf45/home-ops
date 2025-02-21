module "dev-test" {
  source = "github.com/alexrf45/lab//talos-pve?ref=main"

  pve_nodes             = ["home-0", "home-1", "home-2", "home-3", "home-4"]
  cert-manager-manifest = "https://github.com/cert-manager/cert-manager/releases/download/v1.16.3/cert-manager.yaml"
  cluster = {
    name          = "prod"
    env           = "prod"
    endpoint      = "10.3.3.25"
    pve_endpoint  = "10.3.3.2"
    gateway       = "10.3.3.1"
    talos_version = "v1.9.4"
    extensions = [
      "intel-ucode",
      "glibc",
      "iscsi-tools",
      "util-linux-tools",
      "qemu-guest-agent"
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
      allow_scheduling = false
      ip               = "10.3.3.25"
      cores            = 2
      memory           = 8092
      size             = 50

    },
    v2 = {
      install_disk     = "/dev/vda"
      machine_type     = "controlplane"
      node             = "home-1"
      vm_id            = 1001
      datastore_id     = "local-lvm"
      ip               = "10.3.3.26"
      allow_scheduling = true
      cores            = 2
      memory           = 8092
      size             = 50

    },
    v3 = {
      install_disk     = "/dev/vda"
      machine_type     = "controlplane"
      node             = "home-2"
      allow_scheduling = true
      vm_id            = 1002
      datastore_id     = "local-lvm"
      ip               = "10.3.3.27"
      cores            = 2
      memory           = 8092
      size             = 50

    },
    v4 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-3"
      vm_id        = 1003
      datastore_id = "local-lvm"
      ip           = "10.3.3.28"
      cores        = 2
      memory       = 8092
      size         = 50

    },
    v5 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-4"
      vm_id        = 1004
      datastore_id = "local-lvm"
      ip           = "10.3.3.29"
      cores        = 2
      memory       = 8092
      size         = 50

    },
    v6 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-0"
      vm_id        = 1005
      datastore_id = "local-lvm"
      ip           = "10.3.3.30"
      cores        = 2
      memory       = 8092
      size         = 50

    },
    v7 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-1"
      vm_id        = 1006
      datastore_id = "local-lvm"
      ip           = "10.3.3.31"
      cores        = 2
      memory       = 8092
      size         = 50

    },
    v8 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-2"
      vm_id        = 1007
      datastore_id = "local-lvm"
      ip           = "10.3.3.32"
      cores        = 2
      memory       = 8092
      size         = 50

    },
  }
}
