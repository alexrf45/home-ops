#------------------------------------------------------------------------------
# Random IDs for Worker Nodes
#------------------------------------------------------------------------------
resource "random_id" "worker" {
  for_each    = var.worker_nodes
  byte_length = 4

  keepers = {
    proxmox_host = each.value.proxmox_host
  }
}

#------------------------------------------------------------------------------
# Worker VMs
# - Can be added/removed without affecting control plane
# - No prevent_destroy (workers are replaceable)
# - Per-worker storage disk count configuration
#------------------------------------------------------------------------------
resource "proxmox_virtual_environment_vm" "worker" {
  for_each = var.worker_nodes

  depends_on = [
    proxmox_virtual_environment_download_file.talos_worker_image,
    # Workers should only be created after control plane exists
    proxmox_virtual_environment_vm.controlplane
  ]

  name            = "${var.environment}-${var.cluster.name}-wk-${random_id.worker[each.key].hex}"
  node_name       = each.value.proxmox_host
  description     = "Talos Worker Node - ${var.cluster.name} (${var.environment})"
  tags            = concat(["k8s", "worker", var.environment, var.cluster.name], each.value.extra_tags)
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
    file_id      = proxmox_virtual_environment_download_file.talos_worker_image[0].id
    file_format  = "raw"
    ssd          = true
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    size         = each.value.disk_size
  }

  # Storage Disks - configurable count per worker
  dynamic "disk" {
    for_each = range(each.value.storage_disk_count)
    content {
      datastore_id = each.value.storage_id
      interface    = "virtio${disk.value + 1}"
      file_format  = "raw"
      ssd          = true
      iothread     = true
      cache        = "writethrough"
      discard      = "on"
      size         = each.value.storage_size
    }
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

  # Workers have more flexible lifecycle than control plane
  # - No prevent_destroy (workers are replaceable)
  # - Targeted ignores only for fields that shouldn't trigger recreation
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
