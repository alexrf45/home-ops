module "dev-test" {
  source = "github.com/alexrf45/lab//talos-pve?ref=patch"

  pve_nodes             = ["cairo", "anubis", "osiris"]
  cert-manager-manifest = "https://github.com/cert-manager/cert-manager/releases/download/v1.16.3/cert-manager.yaml"
  cluster = {
    name          = "staging"
    env           = "staging"
    endpoint      = "10.3.3.40"
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
      vm_id            = 1000
      datastore_id     = "local-lvm"
      allow_scheduling = true
      ip               = "10.3.3.40"
      cores            = 2
      memory           = 8092
      size             = 25

    },
    v2 = {
      install_disk     = "/dev/vda"
      machine_type     = "worker"
      allow_scheduling = true
      node             = "anubis"
      vm_id            = 1001
      datastore_id     = "local-lvm"
      ip               = "10.3.3.41"
      cores            = 2
      memory           = 8092
      size             = 25

    },
    v3 = {
      install_disk = "/dev/vda"
      machine_type = "worker"
      node         = "osiris"
      vm_id        = 1002
      datastore_id = "local-lvm"
      ip           = "10.3.3.43"
      cores        = 2
      memory       = 8092
      size         = 25

    },
  }
}
