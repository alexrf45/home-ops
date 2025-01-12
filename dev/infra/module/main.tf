resource "proxmox_virtual_environment_download_file" "talos_image" {
  for_each                = var.controlplanes
  content_type            = "iso"
  datastore_id            = var.cluster.iso_datastore
  node_name               = each.value.host_node
  url                     = data.talos_image_factory_urls.this.urls.disk_image
  decompression_algorithm = "zst"
  file_name               = "talos.img"
  #overwrite               = true
  #overwrite_unmanaged     = true
}
resource "proxmox_virtual_environment_download_file" "talos_image_2" {
  for_each                = var.nodes
  content_type            = "iso"
  datastore_id            = var.cluster.iso_datastore
  node_name               = each.value.host_node
  url                     = data.talos_image_factory_urls.this.urls.disk_image
  decompression_algorithm = "zst"
  file_name               = "talos.img"
  #overwrite               = true
  #overwrite_unmanaged     = true
}
resource "proxmox_virtual_environment_vm" "talos_vm_control_plane" {
  for_each        = var.controlplanes
  name            = each.key
  node_name       = each.value.host_node
  description     = each.value.machine_type == "controlplane" ? "Talos Control Plane" : "Talos Worker"
  tags            = each.value.machine_type == "controlplane" ? ["k8s", "control-plane"] : ["k8s", "worker"]
  vm_id           = each.value.vm_id
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
    file_id      = proxmox_virtual_environment_download_file.talos_image[each.key].id
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
        address = "${each.value.ip}/24"
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
  depends_on      = [proxmox_virtual_environment_vm.talos_vm_control_plane, talos_machine_bootstrap.this, talos_machine_configuration_apply.this]
  for_each        = var.nodes
  name            = each.key
  node_name       = each.value.host_node
  description     = each.value.machine_type == "controlplane" ? "Talos Control Plane" : "Talos Worker"
  tags            = each.value.machine_type == "controlplane" ? ["k8s", "control-plane"] : ["k8s", "worker"]
  vm_id           = each.value.vm_id
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
    file_id      = proxmox_virtual_environment_download_file.talos_image_2[each.key].id
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
        address = "${each.value.ip}/24"
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
