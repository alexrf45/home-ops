variable "pve_hosts" {
  description = "hostname/id of pve host"
  type        = list(string)
  default     = ["pve"]
}

variable "pve_config" {
  description = "values for pve virtual machines"
  type = object({
    pve_endpoint              = string
    gateway                   = string
    control_plane_description = string
    control_plane_tags        = list(string)
    worker_description        = string
    worker_tags               = list(string)
    iso_datastore             = string
  })
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name                     = string
    env                      = string
    endpoint                 = string
    node_network             = string
    vip_ip                   = string
    nameserver1              = string
    nameserver2              = string
    talos_version            = string
    platform                 = string
    install_disk             = string
    tailscale_auth           = string
    control_plane_extensions = list(string)
    worker_extensions        = list(string)

  })
}

variable "nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    machine_type     = string
    node             = string
    ip               = string
    datastore_id     = string
    storage_id       = string
    allow_scheduling = optional(bool, true)
    cores            = number
    memory           = number
    size             = number
    storage_size     = number
  }))
}

variable "cilium_config" {
  description = "configuration options for bootstraping cilium"
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
