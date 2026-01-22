variable "environment" {
  description = "operating environment of cluster"
  type        = string
  validation {
    condition = anytrue([
      var.environment == "dev",
      var.environment == "staging",
      var.environment == "production",
      var.environment == "testing",
    ])
    error_message = "Please use one of the approved environement names: dev, staging, production, testing"
  }
}

variable "pve_config" {
  description = "Proxmox VE configuration options"
  type = object({
    hosts         = list(string)
    pve_endpoint  = string
    iso_datastore = string
    igpu          = optional(bool, false)
    gateway       = string
    password      = string
  })
}
variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name                     = string
    endpoint                 = string
    vip_ip                   = string
    talos_version            = string
    install_disk             = string
    storage_disk             = string
    control_plane_extensions = list(string)
    worker_extensions        = list(string)
    platform                 = string
    tailscale_auth           = string
  })
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.cluster.name)) && length(var.cluster.name) >= 4
    error_message = "Cluster name must contain only alphanumeric characters and be at least 4 characters long."
  }
}


variable "nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    machine_type     = string
    allow_scheduling = optional(bool, true)
    node             = string
    ip               = string
    cores            = number
    memory           = number
    datastore_id     = optional(string, "local-lvm")
    storage_id       = string
    size             = number
    storage_size     = number
  }))
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
variable "cilium_config" {
  description = "Configuration options for bootstrapping cilium"
  type = object({
    node_network               = string
    kube_version               = string
    cilium_version             = string
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
  default = {
    node_network               = "10.3.3.0/24"
    kube_version               = "1.33.0"
    cilium_version             = "1.17.6"
    hubble_enabled             = false
    hubble_ui_enabled          = false
    relay_enabled              = false
    relay_pods_rollout         = false
    ingress_controller_enabled = true
    ingress_default_controller = true
    gateway_api_enabled        = false
    load_balancer_mode         = "shared"
    load_balancer_ip           = "10.3.3.2"
    load_balancer_start        = 10
    load_balancer_stop         = 20
  }
}
