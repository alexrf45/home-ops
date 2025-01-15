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

variable "node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      install_disk  = string
      install_image = string
      hostname      = optional(string)
    }))
    workers = map(object({
      install_disk  = string
      install_image = string
      hostname      = optional(string)
    }))
  })
  default = {
    controlplanes = {
      "192.168.1.150" = {
        install_disk  = "/dev/vda"
        install_image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.2"
      },
    }
    workers = {
      "192.168.1.151" = {
        install_disk  = "/dev/vda"
        install_image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.2"
      },
      "192.168.1.152" = {
        install_disk  = "/dev/vda"
        install_image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.8.2"
      }
    }
  }
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
  default     = "v1.9.1"

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
