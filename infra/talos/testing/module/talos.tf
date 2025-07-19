# talos.tf
resource "talos_machine_secrets" "this" {
  talos_version = var.cluster.talos_version
}

data "talos_client_configuration" "this" {
  depends_on = [
    proxmox_virtual_environment_vm.control_plane,
    proxmox_virtual_environment_vm.worker
  ]
  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = local.all_node_ips
  endpoints            = local.control_plane_ips
}

# Control plane machine configurations
data "talos_machine_configuration" "control_plane" {
  count            = var.node_config.control_plane_count
  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${var.cluster.endpoint}:6443"
  talos_version    = var.cluster.talos_version
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [
    templatefile("${path.module}/templates/control_plane.yaml.tftpl", {
      hostname         = format("%s-controlplane-%d", var.cluster.env, count.index + 1)
      allow_scheduling = var.cluster.allow_scheduling
      cluster_name     = var.cluster.name
      vip_ip           = var.cluster.vip_ip
      install_disk     = var.cluster.install_disk
      install_image    = talos_image_factory_schematic.controlplane.id
      nameserver1      = var.dns_servers.primary
      nameserver2      = var.dns_servers.secondary
    }),
    templatefile("${path.module}/templates/patch.yaml.tftpl", {
      tailscale_auth = var.cluster.tailscale_auth
    }),
    yamlencode({
      cluster = {
        inlineManifests = count.index == 0 ? [
          {
            name = "cilium"
            contents = join("---\n", [
              data.helm_template.this.manifest,
              "# Source cilium.tf\n${local.cilium_lb_manifest}",
            ])
          }
        ] : []
      }
    }),
  ]
}

# Worker machine configurations
data "talos_machine_configuration" "worker" {
  count            = var.node_config.worker_count
  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${var.cluster.endpoint}:6443"
  talos_version    = var.cluster.talos_version
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [
    templatefile("${path.module}/templates/node.yaml.tftpl", {
      install_disk  = var.cluster.install_disk
      install_image = talos_image_factory_schematic.worker.id
      environment   = var.cluster.env
      hostname      = format("%s-worker-%d", var.cluster.name, count.index + 1)
      nameserver1   = var.dns_servers.primary
      nameserver2   = var.dns_servers.secondary
    }),
  ]
}

# Apply control plane configurations
resource "talos_machine_configuration_apply" "control_plane" {
  count                       = var.node_config.control_plane_count
  depends_on                  = [proxmox_virtual_environment_vm.control_plane]
  apply_mode                  = "auto"
  node                        = local.control_plane_ips[count.index]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane[count.index].machine_configuration

  timeouts = {
    create = "5m"
  }

  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_vm.control_plane[count.index]]
  }
}

# Apply worker configurations
resource "talos_machine_configuration_apply" "worker" {
  count                       = var.node_config.worker_count
  depends_on                  = [proxmox_virtual_environment_vm.worker]
  apply_mode                  = "auto"
  node                        = local.worker_ips[count.index]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[count.index].machine_configuration

  timeouts = {
    create = "5m"
  }

  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_vm.worker[count.index]]
  }
}

# Bootstrap the first control plane node
resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.control_plane,
    talos_machine_configuration_apply.worker
  ]
  node                 = local.control_plane_ips[0]
  endpoint             = var.cluster.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration

  timeouts = {
    create = "5m"
  }
}

resource "time_sleep" "wait_until_bootstrap" {
  depends_on      = [talos_machine_bootstrap.this]
  create_duration = "1m"
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [time_sleep.wait_until_bootstrap]
  node                 = local.control_plane_ips[0]
  endpoint             = var.cluster.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration

  timeouts = {
    read   = "1m"
    create = "5m"
  }
}
