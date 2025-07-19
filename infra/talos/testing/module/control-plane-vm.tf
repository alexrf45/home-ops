# control-plane-vm.tf
resource "proxmox_virtual_environment_vm" "control_plane" {
  count           = var.node_config.control_plane_count
  name            = format("cp-%s-%d", random_id.cluster.id, count.index + 1)
  node_name       = var.pve_config.hosts[count.index % length(var.pve_config.hosts)]
  description     = var.cluster.control_plane_description
  tags            = var.cluster.control_plane_tags
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
    cores = var.node_config.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.node_config.memory
  }

  efi_disk {
    type = "4m"
  }

  disk {
    datastore_id = var.node_config.datastore_id
    interface    = "virtio0"
    file_id      = proxmox_virtual_environment_download_file.talos_control_plane_image[0].id
    file_format  = "raw"
    ssd          = true
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    size         = var.node_config.disk_size
  }

  disk {
    datastore_id = var.node_config.storage_id
    interface    = "virtio1"
    file_format  = "raw"
    ssd          = true
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    size         = var.node_config.storage_size
  }

  initialization {
    dns {
      servers = [var.dns_servers.primary, var.dns_servers.secondary]
    }
    ip_config {
      ipv4 {
        address = "${local.control_plane_ips[count.index]}/24"
        gateway = var.cluster.gateway
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
