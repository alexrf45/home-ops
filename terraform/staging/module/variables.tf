variable "pve_nodes" {
  description = "hostname/id of pve host"
  type        = list(string)
  default     = ["pve"]
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name          = string
    env           = string
    endpoint      = string
    pve_endpoint  = string
    gateway       = string
    talos_version = string
    extensions    = list(string)
    platform      = string
    iso_datastore = string
  })
}


variable "nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    install_disk     = string
    machine_type     = string
    node             = string
    ip               = string
    vm_id            = number
    datastore_id     = string
    allow_scheduling = optional(bool, true)
    cores            = number
    memory           = number
    size             = number
  }))
}

variable "cert-manager-manifest" {
  description = "url of cert-manager manifest"
  default     = "https://github.com/cert-manager/cert-manager/releases/download/v1.16.3/cert-manager.yaml"
}


variable "node_network" {
  description = "The IP network of the cluster nodes"
  type        = string
  default     = "10.3.3.0/24"
}


variable "load_balancer_start" {
  description = "The hostnum of the first load balancer host"
  type        = number
  default     = 70
}

variable "load_balancer_stop" {
  description = "The hostnum of the last load balancer host"
  type        = number
  default     = 150
}
