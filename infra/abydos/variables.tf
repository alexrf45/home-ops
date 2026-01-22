variable "env" {
  description = "Operating env of cluster (dev, test, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.env)
    error_message = "Please use one of the approved environement names: dev, staging, prod, test"
  }
}

variable "pve" {
  description = "Proxmox VE configuration options"
  type = object({
    hosts         = list(string)
    endpoint      = string
    iso_datastore = optional(string, "local")
    gateway       = string
    password      = string

  })
  sensitive = true
}
variable "talos" {
  description = "Cluster configuration"
  type = object({
    name                     = optional(string, "k8s-cluster")
    endpoint                 = string
    vip_ip                   = string
    version                  = string
    install_disk             = optional(string, "/dev/vda")
    storage_disk             = optional(string, "/var/data")
    control_plane_extensions = list(string)
    worker_extensions        = list(string)
    platform                 = optional(string, "nocloud")
  })
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.talos.name)) && length(var.talos.name) >= 4
    error_message = "Cluster name must contain only alphanumeric characters and be at least 4 characters long."
  }
}


variable "controlplane_nodes" {
  description = "Control plane node configurations - changes here won't affect workers"
  type = map(object({
    node             = string
    ip               = string
    cores            = optional(number, 2)
    memory           = optional(number, 8192)
    allow_scheduling = optional(bool, false)
    datastore_id     = optional(string, "local-lvm")
    storage_id       = string
    disk_size        = optional(number, 50)
    storage_size     = optional(number, 100)
  }))
  validation {
    condition     = length(var.controlplane_nodes) >= 1 && length(var.controlplane_nodes) % 2 == 1
    error_message = "Control plane requires an odd number of nodes (1, 3, or 5) for etcd quorum"
  }
}

variable "worker_nodes" {
  description = "Worker node configurations - can be scaled independently without affecting control plane"
  type = map(object({
    node         = string
    ip           = string
    cores        = optional(number, 2)
    memory       = optional(number, 8092)
    datastore_id = optional(string, "local-lvm")
    storage_id   = string
    disk_size    = optional(number, 50)
    storage_size = optional(number, 200)
  }))
  default = {}
}


#permits adding additonal worker nodes
#and repeating cluster bootstrap

variable "bootstrap_cluster" {
  description = "Whether to bootstrap the cluster. Set to false after initial deployment to prevent bootstrap failures on re-apply."
  type        = bool
  default     = true
}

variable "nameservers" {
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
    namespace                  = optional(string, "networking")
    node_network               = string
    kube_version               = string
    cilium_version             = string
    hubble_enabled             = optional(bool, false)
    hubble_ui_enabled          = optional(bool, false)
    relay_enabled              = optional(bool, false)
    relay_pods_rollout         = optional(bool, false)
    ingress_controller_enabled = optional(bool, true)
    ingress_default_controller = optional(bool, true)
    gateway_api_enabled        = optional(bool, true)
    load_balancer_mode         = optional(string, "shared")
    load_balancer_ip           = string
    load_balancer_start        = number
    load_balancer_stop         = number
  })
  default = {
    namespace                  = "networking"
    node_network               = "192.168.20.0/24"
    kube_version               = "1.33.0"
    cilium_version             = "1.18.0"
    hubble_enabled             = false
    hubble_ui_enabled          = false
    relay_enabled              = false
    relay_pods_rollout         = false
    ingress_controller_enabled = true
    ingress_default_controller = true
    gateway_api_enabled        = false
    load_balancer_mode         = "shared"
    load_balancer_ip           = "192.168.20.100"
    load_balancer_start        = 100
    load_balancer_stop         = 115
  }
}
