variable "environment" {
  description = "operating environment of cluster"
  type        = string
  validation {
    condition = anytrue([
      var.environment == "dev",
      var.environment == "staging",
      var.environment == "production",
      var.environment == "testing",
      var.environment == "sandbox",
    ])
    error_message = "Please use one of the approved environement names: dev, staging, production, testing, sandbox"
  }
}

variable "pve_config" {
  description = "Proxmox VE configuration options"
  type = object({
    hosts         = list(string)
    pve_endpoint  = string
    igpu          = optional(bool, true)
    iso_datastore = string
    gateway       = string
    password      = string
  })
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
    datastore_id     = string
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

resource "proxmox_virtual_environment_vm" "this" {
  depends_on = [
  ]
  for_each        = var.nodes
  name            = "pve-backup-srv-001"
  node_name       = each.value.node
  description     = "pve backup server"
  tags            = ["backup", "vm", "${var.environment}"]
  machine         = "q35"
  scsi_hardware   = "virtio-scsi-single"
  stop_on_destroy = true
  bios            = "ovmf"
  on_boot         = true

  agent {
    enabled = true
    trim    = true
  }
  cpu {
    cores = each.value.cores
    type  = "x86-64-v2-AES"
  }
  memory {
    dedicated = each.value.memory
  }
  tpm_state {
    datastore_id = each.value.datastore_id
    version      = "v2.0"
  }
  efi_disk {
    datastore_id = each.value.datastore_id
    file_format  = "raw"
    type         = "4m"
  }
  disk {
    datastore_id = each.value.datastore_id
    interface    = "virtio0"
    file_id      = ""
    file_format  = "raw"
    ssd          = true
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    size         = each.value.size
  }
  disk {
    datastore_id = each.value.storage_id
    interface    = "virtio1"
    file_format  = "raw"
    ssd          = true
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    size         = each.value.storage_size
  }
  disk {
    datastore_id = each.value.storage_id
    interface    = "virtio2"
    file_format  = "raw"
    ssd          = true
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    size         = each.value.size
  }
  initialization {
    datastore_id = each.value.datastore_id
    dns {
      servers = [
        "${var.dns_servers.primary}",
        "${var.dns_servers.secondary}"
      ]
    }
    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.pve_config.gateway
      }
    }
  }
  network_device {
    bridge = "vmbr0"
  }

  boot_order = ["virtio0"]

  operating_system {
    type = "l26"
  }
}

