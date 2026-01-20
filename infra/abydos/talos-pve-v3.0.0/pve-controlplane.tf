# pve-controlplane.tf - Control Plane VM resources
resource "random_id" "controlplane" {
  for_each    = var.controlplane_nodes
  byte_length = 4

  keepers = {
    # Only regenerate if the node moves to a different Proxmox host
    proxmox_host = each.value.proxmox_host
  }
}

#------------------------------------------------------------------------------
# Control Plane VMs
#------------------------------------------------------------------------------
resource "proxmox_virtual_environment_vm" "controlplane" {
  for_each = var.controlplane_nodes

  depends_on = [
    proxmox_virtual_environment_download_file.talos_controlplane_image
  ]

  name            = "${var.environment}-${var.cluster.name}-cp-${random_id.controlplane[each.key].hex}"
  node_name       = each.value.proxmox_host
  description     = "Talos Control Plane - ${var.cluster.name} (${var.environment})"
  tags            = ["k8s", "controlplane", var.environment, var.cluster.name]
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

  # OS Disk
  disk {
    datastore_id = each.value.datastore_id
    interface    = "virtio0"
    file_id      = proxmox_virtual_environment_download_file.talos_controlplane_image[0].id
    file_format  = "raw"
    ssd          = true
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    size         = each.value.disk_size
  }

  # Storage Disk (single disk for control plane)
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
      servers = local.dns_servers_list
    }
    ip_config {
      ipv4 {
        address = "${each.value.ip}/${var.network.prefix_length}"
        gateway = var.pve_hosts.gateway
      }
    }
  }

  network_device {
    bridge = var.network.bridge
  }

  boot_order = ["virtio0"]

  operating_system {
    type = "l26"
  }

  lifecycle {
    prevent_destroy = true

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
