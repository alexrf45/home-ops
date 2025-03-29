module "dev-test" {
  source = "./module-bare-metal"

  cluster = {
    name          = "staging"
    env           = "staging"
    endpoint      = "10.3.3.80"
    vip_ip        = "10.3.3.79"
    gateway       = "10.3.3.1"
    talos_version = "v1.9.5"
    extensions = [
      "intel-ucode",
      "glibc",
      "iscsi-tools",
      "util-linux-tools",
      "qemu-guest-agent",
      "i915",
      "usb-mode-drivers",
      "v4l-uvc-drivers",
      "zfs",
      "realtek-firmware"
    ]
    platform = "metal"
  }

  nodes = {
    v1 = {
      install_disk     = "/dev/nvme0n1"
      storage_disk     = "dev/sda"
      machine_type     = "controlplane"
      allow_scheduling = true
      ip               = "10.3.3.2"

    },
    v2 = {
      install_disk     = "/dev/nvme0n1"
      storage_disk     = "dev/sda"
      machine_type     = "controlplane"
      allow_scheduling = true
      ip               = "10.3.3.3"

    },
    v3 = {
      install_disk     = "/dev/nvme0n1"
      storage_disk     = "dev/sda"
      machine_type     = "controlplane"
      allow_scheduling = true
      ip               = "10.3.3.4"

    },
    v4 = {
      install_disk = "/dev/nvme0n1"
      storage_disk = "dev/sda"
      machine_type = "worker"
      ip           = "10.3.3.5"

    },
    v5 = {
      install_disk = "/dev/nvme0n1"
      storage_disk = "dev/sda"
      machine_type = "worker"
      ip           = "10.3.3.6"

    },


  }
}
