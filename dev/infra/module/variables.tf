variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name          = string
    endpoint      = string
    gateway       = string
    talos_version = string
    platform      = string
    iso_datastore = string
  })
}

variable "controlplanes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node    = string
    machine_type = string
    datastore_id = optional(string, "data")
    memory       = number
    size         = number
    storage      = number
    ip           = string
    vm_id        = number
  }))
}
variable "nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node    = string
    machine_type = string
    datastore_id = optional(string, "data")
    memory       = number
    size         = number
    storage      = number
    ip           = string
    vm_id        = number
  }))
}


variable "proxmox_iso_datastore" {
  description = "Datastore to put the image"
  type        = string
  default     = "local"
}


variable "vm_cores" {
  description = "Number of CPU cores for the VMs"
  type        = number
  default     = 2
}



variable "vm_type" {
  description = "proxmox emulated CPU type, x86-64-v2-AES recommended"
  type        = string
  default     = "x86-64-v2-AES"
}


variable "talos_cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "default"
}

variable "talos_version" {
  description = "Version of Talos to use"
  type        = string
  default     = "v1.9.0"

}

variable "platform" {
  description = "type of talos linux image"
  type        = string
  default     = "metal"
}

variable "talos_arch" {
  description = "Architecture of Talos to use"
  type        = string
  default     = "amd64"
}


variable "machine_config_patches" {
  description = "List of YAML patches to apply to the control machine configuration"
  type        = list(string)
  default = [
    <<EOT
machine:
  install:
    disk: "/dev/sda"
EOT
  ]
}
