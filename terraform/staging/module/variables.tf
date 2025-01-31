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

