# pve.tf - Talos VM resources
# resource "random_id" "controlplane" {
#   for_each    = var.controlplane_nodes
#   byte_length = 8
#
#   keepers = {
#     # Only regenerate if the node moves to a different Proxmox host
#     node = each.value.node
#   }
# }
# resource "random_id" "worker" {
#   for_each    = var.worker_nodes
#   byte_length = 8
#
#   keepers = {
#     node = each.value.node
#   }
# }

resource "proxmox_virtual_environment_vm" "controlplane" {
  depends_on = [
    proxmox_virtual_environment_download_file.talos_control_plane_image
  ]
  for_each        = var.controlplane_nodes
  name            = format("${var.env}-${var.talos.name}-cp-${random_id.this[each.key].hex}")
  node_name       = each.value.node
  description     = "Talos Control Plane"
  tags            = ["k8s", "cp", "${var.env}"]
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
    file_id      = proxmox_virtual_environment_download_file.talos_control_plane_image[0].id
    file_format  = "raw"
    ssd          = true
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    size         = each.value.disk_size
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
  initialization {
    datastore_id = each.value.datastore_id
    dns {
      servers = [
        "${var.nameservers.primary}",
        "${var.nameservers.secondary}"
      ]
    }
    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.pve.gateway
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

  lifecycle {
    prevent_destroy = false

    ignore_changes = [
      # Ignore image changes - handle upgrades separately via talosctl
      disk[0].file_id,
      # Ignore cloud-init changes after initial boot
      initialization,
      # Ignore description updates from Proxmox UI
      description,
    ]
  }
}


resource "proxmox_virtual_environment_vm" "worker" {
  depends_on = [
    proxmox_virtual_environment_download_file.talos_worker_image
  ]
  for_each        = var.worker_nodes
  name            = format("${var.env}-${var.talos.name}-node-${random_id.this[each.key].hex}")
  node_name       = each.value.node
  description     = "Talos Node Enivornment"
  tags            = ["k8s", "node", "${var.env}"]
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
    file_id      = proxmox_virtual_environment_download_file.talos_worker_image[0].id
    file_format  = "raw"
    ssd          = true
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    size         = each.value.disk_size
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
  initialization {
    datastore_id = each.value.datastore_id
    dns {
      servers = [
        "${var.nameservers.primary}",
        "${var.nameservers.secondary}"
      ]
    }
    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.pve.gateway
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
  lifecycle {
    ignore_changes = [
      # Ignore image changes - handle upgrades separately
      disk[0].file_id,
      # Ignore cloud-init changes after initial boot
      initialization,
      # Ignore description updates from Proxmox UI
      description,
    ]
  }

}

