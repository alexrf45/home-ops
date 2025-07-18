variable "pve_hosts" {
  description = "hostname/id of pve host"
  type        = list(string)
  default     = ["pve"]
}

variable "gateway" {
  description = "default gateway of node network"
  type        = string
  default     = "10.3.3.1"
}

variable "ns1" {
  description = "primary name server"
  type        = string
  default     = "1.1.1.1"
}

variable "ns2" {
  description = "secondary nameserver"
  type        = string
  default     = "8.8.8.8"
}


variable "controlplane" {
  description = "configuration for worker nodes"
  type = map(object({
    machine_type = string
    node         = string
    ip           = string
    storage_id   = string
    cores        = number
    memory       = number
    size         = number
    storage_size = number
  }))
}

variable "worker" {
  description = "configuration for worker nodes"
  type = map(object({
    machine_type = string
    node         = string
    ip           = string
    storage_id   = string
    cores        = number
    memory       = number
    size         = number
    storage_size = number
  }))
}

variable "talos_config" {
  description = "talos configuration"
  type = object({
    talos_version    = string
    name             = string
    env              = string
    install_disk     = string
    allow_scheduling = optional(bool, true)
  })
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
