resource "proxmox_virtual_environment_download_file" "talos_worker_image" {
  count                   = length(var.pve_hosts)
  content_type            = "iso"
  datastore_id            = var.pve_config.iso_datastore
  node_name               = var.pve_hosts[count.index]
  url                     = data.talos_image_factory_urls.worker.urls.disk_image
  decompression_algorithm = "zst"
  file_name               = "${var.cluster.env}-${random_id.test.id}-worker-talos.img"
  overwrite               = false
  upload_timeout          = 240
}

resource "random_id" "test" {
  byte_length = 5
}


#TODO: Refactor to create a worker and control plane resource
resource "proxmox_virtual_environment_vm" "worker" {
  for_each        = var.worker
  name            = format("cp-%s-%s", random_id.test.id, each.key)
  node_name       = each.value.node
  description     = var.cluster.control_plane_description
  tags            = var.cluser.control_plane_tags
  install_disk    = var.cluster.install_disk
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
  efi_disk {
    type = "4m"
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

  initialization {
    dns {
      servers = ["${var.ns1}", "${var.ns2}"]
    }
    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.gateway
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

