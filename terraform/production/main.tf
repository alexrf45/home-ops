module "dev-test" {
  source = "github.com/alexrf45/lab//talos-pve?ref=patch"

  pve_nodes             = ["home-2", "home-3", "home-4"]
  cert-manager-manifest = "https://github.com/cert-manager/cert-manager/releases/download/v1.16.3/cert-manager.yaml"
  cluster = {
    name          = "prod"
    env           = "prod"
    endpoint      = "10.3.3.50"
    pve_endpoint  = "10.3.3.2"
    gateway       = "10.3.3.1"
    talos_version = "v1.9.1"
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
      node             = "home-2"
      vm_id            = 2000
      datastore_id     = "local-lvm"
      allow_scheduling = false
      ip               = "10.3.3.50"
      cores            = 2
      memory           = 8092
      size             = 25

    },
    v2 = {
      install_disk     = "/dev/vda"
      machine_type     = "controlplane"
      node             = "home-3"
      vm_id            = 2001
      datastore_id     = "local-lvm"
      ip               = "10.3.3.51"
      allow_scheduling = false
      cores            = 2
      memory           = 8092
      size             = 25

    },
    v3 = {
      install_disk     = "/dev/vda"
      machine_type     = "controlplane"
      node             = "home-4"
      allow_scheduling = false
      vm_id            = 2002
      datastore_id     = "local-lvm"
      ip               = "10.3.3.52"
      cores            = 2
      memory           = 8092
      size             = 25

    },
    v4 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-4"
      vm_id        = 2003
      datastore_id = "local-lvm"
      ip           = "10.3.3.53"
      cores        = 2
      memory       = 8092
      size         = 25

    },
    v5 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-3"
      vm_id        = 2004
      datastore_id = "local-lvm"
      ip           = "10.3.3.54"
      cores        = 2
      memory       = 8092
      size         = 25

    },
    v6 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-2"
      vm_id        = 2005
      datastore_id = "local-lvm"
      ip           = "10.3.3.55"
      cores        = 2
      memory       = 8092
      size         = 25

    },
    v7 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "home-0"
      vm_id        = 2006
      datastore_id = "local-lvm"
      ip           = "10.3.3.56"
      cores        = 2
      memory       = 8092
      size         = 25

    },
  }
}
