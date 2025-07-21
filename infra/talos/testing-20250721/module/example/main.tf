module "dev-test" {
  source                = "./module"
  pve_nodes             = ["cairo", "anubis"]
  cert-manager-manifest = "https://github.com/cert-manager/cert-manager/releases/download/v1.16.3/cert-manager.yaml"
  cluster = {
    name          = "dev"
    env           = "dev"
    endpoint      = "10.3.3.60"
    pve_endpoint  = "10.3.3.9"
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
      node             = "cairo"
      vm_id            = 7000
      datastore_id     = "data"
      allow_scheduling = false
      ip               = "10.3.3.60"
      cores            = 2
      memory           = 8092
      size             = 50

    },
    v2 = {
      install_disk     = "/dev/vda"
      machine_type     = "controlplane"
      allow_scheduling = true
      node             = "anubis"
      vm_id            = 7001
      datastore_id     = "data"
      ip               = "10.3.3.61"
      cores            = 2
      memory           = 8092
      size             = 50

    },
    v3 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "cairo"
      vm_id        = 7002
      datastore_id = "data"
      ip           = "10.3.3.62"
      cores        = 2
      memory       = 8092
      size         = 50

    },
  }
}
