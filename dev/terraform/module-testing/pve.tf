resource "proxmox_virtual_environment_download_file" "talos_image" {
  count                   = length(var.pve_nodes)
  content_type            = "iso"
  datastore_id            = var.cluster.iso_datastore
  node_name               = var.pve_nodes[count.index]
  url                     = data.talos_image_factory_urls.this.urls.disk_image
  decompression_algorithm = "zst"
  file_name               = "talos.img"
}

resource "proxmox_virtual_environment_vm" "talos_vm_control_plane" {
  for_each        = var.node_data.controlplanes
  name            = format("k8s-control-plane-%s", index(keys(var.node_data.controlplanes), each.key))
  node_name       = each.value.node
  description     = "K8s Control Plane Node"
  tags            = ["k8s", "controlplane", "talos"]
  machine         = "q35"
  scsi_hardware   = "virtio-scsi-single"
  stop_on_destroy = true
  bios            = "ovmf"

  agent {
    enabled = true
    trim    = true
  }
  cpu {
    cores = var.vm_cores
    type  = var.vm_type
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
    file_id      = proxmox_virtual_environment_download_file.talos_image[0].id
    file_format  = "raw"
    ssd          = true
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    size         = each.value.size
  }

  disk {
    datastore_id = each.value.datastore_id
    interface    = "virtio1"
    file_format  = "raw"
    ssd          = true
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    size         = each.value.storage
  }
  initialization {
    datastore_id = each.value.datastore_id
    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }
    ip_config {
      ipv4 {
        address = "${each.key}/24"
        gateway = var.cluster.gateway
      }
    }
  }
  network_device {
    bridge = "vmbr0"
  }


  boot_order = ["virtio0", "virtio1"]

  operating_system {
    type = "l26"
  }
}

resource "proxmox_virtual_environment_vm" "talos_vm" {
  depends_on = [proxmox_virtual_environment_vm.talos_vm_control_plane]

  for_each        = var.node_data.workers
  name            = format("k8s-node-%s", index(keys(var.node_data.workers), each.key))
  node_name       = each.value.node
  description     = "K8s Worker Node"
  tags            = ["k8s", "worker", "talos"]
  machine         = "q35"
  scsi_hardware   = "virtio-scsi-single"
  stop_on_destroy = true
  bios            = "ovmf"
  agent {
    enabled = true
    trim    = true
  }
  cpu {
    cores = var.vm_cores
    type  = var.vm_type
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
    file_id      = proxmox_virtual_environment_download_file.talos_image[0].id
    file_format  = "raw"
    ssd          = true
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    size         = each.value.size
  }
  disk {
    datastore_id = each.value.datastore_id
    interface    = "virtio1"
    file_format  = "raw"
    ssd          = true
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    size         = each.value.storage
  }

  initialization {
    datastore_id = each.value.datastore_id
    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }
    ip_config {
      ipv4 {
        address = "${each.key}/24"
        gateway = var.cluster.gateway
      }
    }
  }
  network_device {
    bridge = "vmbr0"
  }


  boot_order = ["virtio0", "virtio1"]

  operating_system {
    type = "l26"
  }
}
