# Resource Definiation for the VM Template

#TODO : https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox/latest/components/builder/iso

source "proxmox-iso" "ubuntu-server-noble" {

  # Proxmox Connection Settings
  proxmox_url = "${var.proxmox_url}"
  username    = "${var.username}"
  password    = "${var.password}"
  # (Optional) Skip TLS Verification
  insecure_skip_tls_verify = true

  # VM General Settings
  node                 = var.pve.hosts
  vm_id                = "1000"
  vm_name              = "ubuntu-server-noble"
  template_description = "Ubuntu Server Noble Image"
  task_timeout         = "5m"
  # VM OS Settings
  # (Option 1) Local ISO File
  boot_iso {
      type         = "scsi"
      iso_file     = "local:iso/ubuntu-24.04-live-server-amd64.iso"
      unmount      = true
      iso_checksum = "e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
  }
  qemu_agent = true
  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size    = "100G"
    format       = "qcow2"
    storage_pool = var.disk_storage
    type         = "virtio"
  }
  cores = "2"
  memory = "2048"

  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }
  cloud_init              = true
  cloud_init_storage_pool = var.disk_storage
  boot         = "c"
  boot_wait    = "10s"
  communicator = "ssh"
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  boot_key_interval = "500ms"
  http_directory = "http"

  # (Optional) Bind IP Address and Port
  # http_bind_address       = "0.0.0.0"
  # http_port_min           = 8802
  # http_port_max           = 8802

  ssh_username = "fr3d"

  # (Option 1) Add your Password here
  # ssh_password        = "your-password"
  # - or -
  # (Option 2) Add your Private SSH KEY file here
  ssh_private_key_file    = "~/.ssh/id_rsa"

  # Raise the timeout, when installation takes longer
  ssh_timeout = "30m"
  ssh_pty     = true
}

# Build Definition to create the VM Template
build {

  name    = "ubuntu-server-noble"
  sources = ["source.proxmox-iso.ubuntu-server-noble"]

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }

  # Add additional provisioning scripts here
  # ...
}
