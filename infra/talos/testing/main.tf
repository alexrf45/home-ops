#NOTE: Consider building another helm chart into cluster bootstrap
#NOTE: deploy main module first then build out k8s/flux bootstrap
#TEST: not yet. Will deploy either later tonight or in the morning


module "testing" {
  source = "./module"
  # source    = "git@github.com:alexrf45/lab.git//talos-pve-v1.3.3?ref=v1.4.1"

  #pve hosts
  pve_hosts = ["home-3", "home-4", "home-5"]


  pve_config = {
    pve_endpoint              = "10.3.3.2"
    gateway                   = "10.3.3.1"
    control_plane_description = "test cluster"
    control_plane_tags        = ["k8s", "talos", "test", "control_plane"]
    worker_description        = "test nodes"
    worker_tags               = ["k8s", "talos", "test", "worker"]
    iso_datastore             = "local"
  }
  # talos & pve configuration
  cluster = {
    #proxmox specific
    name           = "testing"
    env            = "testing"
    endpoint       = "10.3.3.101"
    node_network   = "10.3.3.0/24"
    vip_ip         = "10.3.3.101"
    nameserver1    = "1.1.1.1"
    nameserver2    = "10.3.3.11"
    talos_version  = "v1.10.5"
    platform       = "nocloud"
    install_disk   = "/dev/vda"
    tailscale_auth = var.auth_key

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
  }

  # talos vm configuration
  nodes = {
    "1" = {
      machine_type     = "controlplane"
      node             = "home-3"
      datastore_id     = "local-lvm"
      storage_id       = "data"
      allow_scheduling = true
      ip               = "10.3.3.101"
      cores            = 2
      memory           = 8092
      size             = 20
      storage_size     = 50
    },
    "2" = {
      machine_type = "worker"
      node         = "home-4"
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.102"
      cores        = 2
      memory       = 8092
      size         = 25
      storage_size = 50
    },
    "3" = {
      machine_type = "worker"
      node         = "home-5"
      datastore_id = "local-lvm"
      storage_id   = "data"
      ip           = "10.3.3.103"
      cores        = 2
      memory       = 8092
      size         = 25
      storage_size = 50
    },
  }
  # cilium chart values
  cilium_config = {
    kube_version               = "1.33.0"
    version                    = "1.17.6"
    hubble_enabled             = true
    hubble_ui_enabled          = true
    relay_enabled              = true
    relay_pods_rollout         = true
    ingress_controller_enabled = true
    ingress_default_controller = true
    gateway_api_enabled        = true
    load_balancer_mode         = "shared"
    load_balancer_start        = 110
    load_balancer_stop         = 120
    load_balancer_ip           = "10.3.3.110"
  }
}

# module "bootstrap" {
#   depends_on = [module.test]
#   source     = "./bootstrap"
# }
