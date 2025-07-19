resource "proxmox_virtual_environment_vm" "this" {
  for_each        = var.nodes
  name            = each.value.machine_type == "controlplane" ? format("${var.environment}-control-plane-%s-%s", random_id.this.id, each.key) : format("${var.environment}-node-%s-%s", random_id.that.id, each.key)
  node_name       = each.value.node
  description     = each.value.machine_type == "controlplane" ? "Talos CP: ${var.environment}" : "Talos Worker: ${var.environment}"
  tags            = each.value.machine_type == "controlplane" ? ["k8s", "cp", "${var.environment}"] : ["k8s", "worker", "${var.environment}"]
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
    version = "v2.0"
  }
  efi_disk {
    file_format = "raw"
    type        = "4m"
  }
  disk {
    interface   = "virtio0"
    file_id     = each.value.machine_type == "controlplane" ? proxmox_virtual_environment_download_file.talos_control_plane_image[0].id : proxmox_virtual_environment_download_file.talos_worker_image[0].id
    file_format = "raw"
    ssd         = true
    iothread    = true
    cache       = "writethrough"
    discard     = "on"
    size        = each.value.size
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
    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
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

  lifecycle {
    ignore_changes = all
  }
}

