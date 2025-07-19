# variables.tf
variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name                      = string
    env                       = string
    endpoint                  = string
    talos_version             = string
    platform                  = string
    allow_scheduling          = bool
    install_disk              = string
    node_network              = string
    gateway                   = string
    vip_ip                    = string
    control_plane_extensions  = list(string)
    worker_extensions         = list(string)
    tailscale_auth            = string
    control_plane_description = optional(string, "Talos Control Plane")
    control_plane_tags        = optional(list(string), ["talos", "kubernetes", "control-plane"])
  })
}

variable "pve_config" {
  description = "Proxmox VE configuration"
  type = object({
    hosts         = list(string)
    iso_datastore = string
    pve_endpoint  = string
    password      = string
  })
  default = {
    hosts         = ["pve"]
    iso_datastore = "local"
    pve_endpoint  = "https://192.168.101.10:8006"
    password      = "pve1234"
  }
}

variable "node_config" {
  description = "Node configuration"
  type = object({
    control_plane_count = number
    worker_count        = number
    base_ip             = string # e.g., "10.3.3.10" - will increment from here
    cores               = number
    memory              = number
    disk_size           = number
    storage_size        = number
    datastore_id        = string
    storage_id          = string
  })
}

variable "cilium_config" {
  description = "Configuration options for bootstrapping cilium"
  type = object({
    kube_version               = string
    version                    = string
    hubble_enabled             = bool
    hubble_ui_enabled          = bool
    relay_enabled              = bool
    relay_pods_rollout         = bool
    ingress_controller_enabled = bool
    ingress_default_controller = bool
    gateway_api_enabled        = bool
    load_balancer_mode         = string
    load_balancer_ip           = string
    load_balancer_start        = number
    load_balancer_stop         = number
  })
}

variable "dns_servers" {
  description = "DNS servers for the nodes"
  type = object({
    primary   = string
    secondary = string
  })
  default = {
    primary   = "1.1.1.1"
    secondary = "8.8.8.8"
  }
}
