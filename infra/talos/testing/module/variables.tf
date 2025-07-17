variable "pve_nodes" {
  description = "hostname/id of pve host"
  type        = list(string)
  default     = ["pve"]
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name                      = string
    env                       = string
    endpoint                  = string
    pve_endpoint              = string
    node_network              = string
    vip_ip                    = string
    gateway                   = string
    talos_version             = string
    control_plane_extensions  = list(string)
    control_plane_description = string
    control_plane_tags        = list(string)
    worker_extensions         = list(string)
    worker_description        = string
    worker_tags               = list(string)
    platform                  = string
    iso_datastore             = string
    install_disk              = string
    tailscale_auth            = string
  })
}

variable "control_plane_description" {
  type    = string
  default = "Talos Control Plane"
}

variable "control_plane_tags" {
  type    = list(string)
  default = ["k8s", "talos", "pve", "control-plane"]
}

variable "worker_tags" {
  type    = list(string)
  default = ["k8s", "talos", "pve", "worker"]
}

variable "worker_description" {
  type    = string
  default = "Talos Worker"
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
