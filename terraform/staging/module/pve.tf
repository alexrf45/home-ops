resource "proxmox_virtual_environment_role" "proxmox-csi" {
  role_id = "kubernetes-csi"

  privileges = [
    "VM.Monitor",
    "VM.Config.Disk",
    "Datastore.Allocate",
    "Datastore.AllocateSpace",
    "Datastore.Audit"
  ]
}

resource "proxmox_virtual_environment_user" "user" {
  comment         = "Managed by Terraform"
  email           = "kubernetes-csi@pve"
  enabled         = true
  expiration_date = "2034-01-01T22:00:00Z"
  user_id         = "kubernetes-csi@pve"
  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.proxmox-csi.role_id
  }
}

resource "proxmox_virtual_environment_user_token" "user_token" {
  comment               = "Managed by Terraform"
  expiration_date       = "2033-01-01T22:00:00Z"
  token_name            = "${var.cluster.name}-token"
  user_id               = proxmox_virtual_environment_user.user.user_id
  privileges_separation = false
}

resource "proxmox_virtual_environment_download_file" "talos_image" {
  count                   = length(var.pve_nodes)
  content_type            = "iso"
  datastore_id            = var.cluster.iso_datastore
  node_name               = var.pve_nodes[count.index]
  url                     = data.talos_image_factory_urls.this.urls.disk_image
  decompression_algorithm = "zst"
  file_name               = "talos.img"
  overwrite               = false
  upload_timeout          = 120
}

resource "proxmox_virtual_environment_vm" "talos_vm" {
  for_each = var.nodes
  name = each.value.machine_type == "controlplane" ? format("${var.cluster.env}-control-plane-%s",
  index(keys(var.nodes), each.key)) : format("${var.cluster.env}-node-%s", index(keys(var.nodes), each.key))

  node_name       = each.value.node
  description     = each.value.machine_type == "controlplane" ? "Talos Control Plane" : "Talos Worker"
  tags            = each.value.machine_type == "controlplane" ? ["k8s", "control-plane"] : ["k8s", "worker"]
  vm_id           = each.value.vm_id
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
    file_id      = proxmox_virtual_environment_download_file.talos_image[0].id
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

  boot_order = ["virtio0"]

  operating_system {
    type = "l26"
  }

  lifecycle {
    ignore_changes = all
  }
}

