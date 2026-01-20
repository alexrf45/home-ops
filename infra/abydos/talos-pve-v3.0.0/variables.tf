# variables.tf - All variable definitions with improved structure

#------------------------------------------------------------------------------
# Environment Configuration
#------------------------------------------------------------------------------
variable "environment" {
  description = "Operating environment of cluster (dev, test, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod"
  }
}

#------------------------------------------------------------------------------
# Proxmox Configuration
#------------------------------------------------------------------------------
variable "pve_hosts" {
  description = "Proxmox VE configuration options"
  type = object({
    hosts         = list(string)
    endpoint      = string
    iso_datastore = optional(string, "local")
    gateway       = string
    password      = string
  })
  sensitive = true
}

variable "network" {
  description = "Network configuration"
  type = object({
    bridge        = optional(string, "vmbr0")
    prefix_length = optional(number, 24)
  })
  default = {
    bridge        = "vmbr0"
    prefix_length = 24
  }
}

variable "dns_servers" {
  description = "DNS servers for the nodes"
  type = object({
    primary   = string
    secondary = string
  })
  default = {
    primary   = "1.1.1.1"
    secondary = "8.8.8.8"
  }
}

#------------------------------------------------------------------------------
# Cluster Configuration
#------------------------------------------------------------------------------
variable "cluster" {
  description = "Talos Linux Kubernetes cluster configuration"
  type = object({
    name          = string
    endpoint      = string
    vip_ip        = string
    talos_version = string
    install_disk  = optional(string, "/dev/vda")
    platform      = optional(string, "nocloud")
    # Storage paths for kubelet mounts
    storage_disk   = optional(string, "/var/data")
    storage_disk_1 = optional(string, "/var/data")
    storage_disk_2 = optional(string, "/var/data")
    # Extensions for image factory
    control_plane_extensions = list(string)
    worker_extensions        = list(string)
  })
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.cluster.name)) && length(var.cluster.name) >= 4
    error_message = "Cluster name must contain only alphanumeric characters and be at least 4 characters long."
  }
  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+$", var.cluster.talos_version))
    error_message = "Talos version must be in format vX.Y.Z (e.g., v1.10.6)"
  }
}

#------------------------------------------------------------------------------
# Control Plane Nodes (Separate from Workers for Independent Management)
#------------------------------------------------------------------------------
variable "controlplane_nodes" {
  description = "Control plane node configurations - changes here won't affect workers"
  type = map(object({
    proxmox_host     = string
    ip               = string
    cores            = optional(number, 2)
    memory           = optional(number, 8192)
    allow_scheduling = optional(bool, false)
    datastore_id     = optional(string, "local-lvm")
    storage_id       = string
    disk_size        = optional(number, 50)
    storage_size     = optional(number, 100)
  }))
  validation {
    condition     = length(var.controlplane_nodes) >= 1 && length(var.controlplane_nodes) % 2 == 1
    error_message = "Control plane requires an odd number of nodes (1, 3, or 5) for etcd quorum"
  }
}

#------------------------------------------------------------------------------
# Worker Nodes (Independently Scalable)
#------------------------------------------------------------------------------
variable "worker_nodes" {
  description = "Worker node configurations - can be scaled independently without affecting control plane"
  type = map(object({
    proxmox_host       = string
    ip                 = string
    cores              = optional(number, 4)
    memory             = optional(number, 16384)
    datastore_id       = optional(string, "local-lvm")
    storage_id         = string
    disk_size          = optional(number, 50)
    storage_size       = optional(number, 200)
    storage_disk_count = optional(number, 2)
    node_labels        = optional(map(string), {})
    extra_tags         = optional(list(string), [])
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Encryption Configuration
#------------------------------------------------------------------------------
variable "encryption" {
  description = "Disk encryption configuration"
  type = object({
    enabled    = bool
    tpm_based  = bool
    static_key = optional(string, "")
  })
  default = {
    enabled    = false
    tpm_based  = true
    static_key = ""
  }
  sensitive = true
}

#------------------------------------------------------------------------------
# Bootstrap Configuration
#------------------------------------------------------------------------------
variable "bootstrap_cluster" {
  description = "Whether to bootstrap the cluster. Set to false after initial deployment to prevent bootstrap failures on re-apply."
  type        = bool
  default     = true
}

variable "wait_for_bootstrap_timeout" {
  description = "Timeout in seconds to wait for cluster bootstrap"
  type        = number
  default     = 300
}

#------------------------------------------------------------------------------
# Cilium CNI Configuration
#------------------------------------------------------------------------------
variable "deploy_cilium" {
  description = "Deploy Cilium CNI via Terraform. Set to false if using GitOps (Flux) for CNI deployment."
  type        = bool
  default     = true
}

variable "cilium_config" {
  description = "Configuration options for Cilium CNI"
  type = object({
    namespace                  = optional(string, "networking")
    node_network               = string
    kube_version               = string
    cilium_version             = string
    hubble_enabled             = optional(bool, false)
    hubble_ui_enabled          = optional(bool, false)
    relay_enabled              = optional(bool, false)
    relay_pods_rollout         = optional(bool, false)
    ingress_controller_enabled = optional(bool, true)
    ingress_default_controller = optional(bool, true)
    gateway_api_enabled        = optional(bool, true)
    load_balancer_mode         = optional(string, "shared")
    load_balancer_ip           = string
    load_balancer_start        = number
    load_balancer_stop         = number
  })
  default = {
    namespace                  = "networking"
    node_network               = "10.3.3.0/24"
    kube_version               = "1.33.0"
    cilium_version             = "1.18.0"
    hubble_enabled             = false
    hubble_ui_enabled          = false
    relay_enabled              = false
    relay_pods_rollout         = false
    ingress_controller_enabled = true
    ingress_default_controller = true
    gateway_api_enabled        = true
    load_balancer_mode         = "shared"
    load_balancer_ip           = "10.3.3.126"
    load_balancer_start        = 126
    load_balancer_stop         = 136
  }
}

#------------------------------------------------------------------------------
# Advanced Configuration
#------------------------------------------------------------------------------
variable "talos_config" {
  description = "Advanced Talos configuration options"
  type = object({
    hugepages   = optional(string, "2048")
    ntp_servers = optional(list(string), ["time.cloudflare.com"])
    kernel_modules = optional(list(object({
      name = string
      })), [
      { name = "nvme_tcp" },
      { name = "vfio_pci" },
      { name = "dm_crypt" },
      { name = "dm_mod" }
    ])
    extra_kernel_args = optional(list(string), [
      "console=ttyS1",
      "panic=10",
      "cpufreq.default_governor=performance",
      "intel_idle.max_cstate=0",
      "disable_ipv6=1"
    ])
    pod_subnets     = optional(list(string), ["10.42.0.0/16"])
    service_subnets = optional(list(string), ["10.43.0.0/16"])
    cluster_dns     = optional(list(string), ["10.43.0.10"])
  })
  default = {}
}

variable "security_config" {
  description = "Security configuration options"
  type = object({
    enable_pod_security_admission = optional(bool, true)
    audit_log_level               = optional(string, "Metadata")
    psa_exempt_namespaces         = optional(list(string), ["networking", "storage", "monitoring"])
  })
  default = {}
}
