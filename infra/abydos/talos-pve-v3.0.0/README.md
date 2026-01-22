## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.0.2 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.80.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.2 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.9.0-alpha.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.0.2 |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.80.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.9.0-alpha.0 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_download_file.talos_control_plane_image](https://registry.terraform.io/providers/bpg/proxmox/0.80.0/docs/resources/virtual_environment_download_file) | resource |
| [proxmox_virtual_environment_download_file.talos_worker_image](https://registry.terraform.io/providers/bpg/proxmox/0.80.0/docs/resources/virtual_environment_download_file) | resource |
| [proxmox_virtual_environment_vm.talos_vm](https://registry.terraform.io/providers/bpg/proxmox/0.80.0/docs/resources/virtual_environment_vm) | resource |
| [random_id.example](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/id) | resource |
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/cluster_kubeconfig) | resource |
| [talos_image_factory_schematic.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/image_factory_schematic) | resource |
| [talos_image_factory_schematic.worker](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/image_factory_schematic) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/resources/machine_secrets) | resource |
| [time_sleep.wait_until_apply](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_until_bootstrap](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [helm_template.this](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/data-sources/template) | data source |
| [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/client_configuration) | data source |
| [talos_image_factory_extensions_versions.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/image_factory_extensions_versions) | data source |
| [talos_image_factory_extensions_versions.worker](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/image_factory_extensions_versions) | data source |
| [talos_image_factory_urls.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/image_factory_urls) | data source |
| [talos_image_factory_urls.worker](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/image_factory_urls) | data source |
| [talos_machine_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.9.0-alpha.0/docs/data-sources/machine_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cilium_config"></a> [cilium\_config](#input\_cilium\_config) | Configuration options for bootstrapping cilium | <pre>object({<br/>    node_network               = string<br/>    kube_version               = string<br/>    cilium_version             = string<br/>    hubble_enabled             = bool<br/>    hubble_ui_enabled          = bool<br/>    relay_enabled              = bool<br/>    relay_pods_rollout         = bool<br/>    ingress_controller_enabled = bool<br/>    ingress_default_controller = bool<br/>    gateway_api_enabled        = bool<br/>    load_balancer_mode         = string<br/>    load_balancer_ip           = string<br/>    load_balancer_start        = number<br/>    load_balancer_stop         = number<br/>  })</pre> | <pre>{<br/>  "cilium_version": "1.17.6",<br/>  "gateway_api_enabled": false,<br/>  "hubble_enabled": false,<br/>  "hubble_ui_enabled": false,<br/>  "ingress_controller_enabled": true,<br/>  "ingress_default_controller": true,<br/>  "kube_version": "1.33.0",<br/>  "load_balancer_ip": "10.3.3.2",<br/>  "load_balancer_mode": "shared",<br/>  "load_balancer_start": 10,<br/>  "load_balancer_stop": 20,<br/>  "node_network": "10.3.3.0/24",<br/>  "relay_enabled": false,<br/>  "relay_pods_rollout": false<br/>}</pre> | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster configuration | <pre>object({<br/>    name                     = string<br/>    endpoint                 = string<br/>    vip_ip                   = string<br/>    talos_version            = string<br/>    install_disk             = string<br/>    storage_disk             = string<br/>    control_plane_extensions = list(string)<br/>    worker_extensions        = list(string)<br/>    platform                 = string<br/>    tailscale_auth           = string<br/>  })</pre> | n/a | yes |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | DNS servers for the nodes | <pre>object({<br/>    primary   = string<br/>    secondary = string<br/>  })</pre> | <pre>{<br/>  "primary": "1.1.1.1",<br/>  "secondary": "8.8.8.8"<br/>}</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | operating environment of cluster | `string` | n/a | yes |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | Configuration for cluster nodes | <pre>map(object({<br/>    machine_type     = string<br/>    allow_scheduling = optional(bool, true)<br/>    node             = string<br/>    ip               = string<br/>    cores            = number<br/>    memory           = number<br/>    datastore_id     = string<br/>    storage_id       = string<br/>    size             = number<br/>    storage_size     = number<br/>  }))</pre> | n/a | yes |
| <a name="input_pve_config"></a> [pve\_config](#input\_pve\_config) | Proxmox VE configuration options | <pre>object({<br/>    hosts         = list(string)<br/>    pve_endpoint  = string<br/>    igpu          = optional(bool, false)<br/>    iso_datastore = string<br/>    gateway       = string<br/>    password      = string<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_configuration"></a> [client\_configuration](#output\_client\_configuration) | n/a |
| <a name="output_kubeclientconfig"></a> [kubeclientconfig](#output\_kubeclientconfig) | n/a |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | n/a |
