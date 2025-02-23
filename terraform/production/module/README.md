<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_flux"></a> [flux](#requirement\_flux) | 1.4.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 6.4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.17.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.69.0 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | >= 0.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.17.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.69.0 |
| <a name="provider_talos"></a> [talos](#provider\_talos) | >= 0.7.0 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Resources

| Name | Type |
|------|------|
| [local_sensitive_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [local_sensitive_file.talosconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [proxmox_virtual_environment_download_file.talos_image](https://registry.terraform.io/providers/bpg/proxmox/0.69.0/docs/resources/virtual_environment_download_file) | resource |
| [proxmox_virtual_environment_vm.talos_vm](https://registry.terraform.io/providers/bpg/proxmox/0.69.0/docs/resources/virtual_environment_vm) | resource |
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/cluster_kubeconfig) | resource |
| [talos_image_factory_schematic.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/image_factory_schematic) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_secrets) | resource |
| [time_sleep.wait_until_bootstrap](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [helm_template.cilium_template](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/data-sources/template) | data source |
| [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/client_configuration) | data source |
| [talos_image_factory_extensions_versions.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/image_factory_extensions_versions) | data source |
| [talos_image_factory_urls.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/image_factory_urls) | data source |
| [talos_machine_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster configuration | <pre>object({<br/>    name          = string<br/>    env           = string<br/>    endpoint      = string<br/>    pve_endpoint  = string<br/>    gateway       = string<br/>    talos_version = string<br/>    extensions    = list(string)<br/>    platform      = string<br/>    iso_datastore = string<br/>  })</pre> | n/a | yes |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | Configuration for cluster nodes | <pre>map(object({<br/>    install_disk     = string<br/>    machine_type     = string<br/>    node             = string<br/>    ip               = string<br/>    vm_id            = number<br/>    datastore_id     = string<br/>    allow_scheduling = optional(bool, true)<br/>    cores            = number<br/>    memory           = number<br/>    size             = number<br/>  }))</pre> | n/a | yes |
| <a name="input_cert-manager-manifest"></a> [cert-manager-manifest](#input\_cert-manager-manifest) | url of cert-manager manifest | `string` | `"https://github.com/cert-manager/cert-manager/releases/download/v1.16.3/cert-manager.yaml"` | no |
| <a name="input_load_balancer_start"></a> [load\_balancer\_start](#input\_load\_balancer\_start) | The hostnum of the first load balancer host | `number` | `70` | no |
| <a name="input_load_balancer_stop"></a> [load\_balancer\_stop](#input\_load\_balancer\_stop) | The hostnum of the last load balancer host | `number` | `150` | no |
| <a name="input_node_network"></a> [node\_network](#input\_node\_network) | The IP network of the cluster nodes | `string` | `"10.3.3.0/24"` | no |
| <a name="input_pve_nodes"></a> [pve\_nodes](#input\_pve\_nodes) | hostname/id of pve host | `list(string)` | <pre>[<br/>  "pve"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_configuration"></a> [client\_configuration](#output\_client\_configuration) | n/a |
| <a name="output_installer_disk_image"></a> [installer\_disk\_image](#output\_installer\_disk\_image) | n/a |
| <a name="output_installer_image_iso"></a> [installer\_image\_iso](#output\_installer\_image\_iso) | n/a |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | n/a |
| <a name="output_machine_config"></a> [machine\_config](#output\_machine\_config) | n/a |
| <a name="output_schematic_id"></a> [schematic\_id](#output\_schematic\_id) | n/a |
<!-- END_TF_DOCS -->