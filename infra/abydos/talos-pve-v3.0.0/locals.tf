# locals.tf - Consolidated computed values

locals {
  #----------------------------------------------------------------------------
  # Node Collections (for easy iteration)
  #----------------------------------------------------------------------------
  all_nodes = merge(
    { for k, v in var.controlplane_nodes : k => merge(v, { machine_type = "controlplane" }) },
    { for k, v in var.worker_nodes : k => merge(v, { machine_type = "worker" }) }
  )

  controlplane_ips = [for k, v in var.controlplane_nodes : v.ip]
  worker_ips       = [for k, v in var.worker_nodes : v.ip]
  all_node_ips     = concat(local.controlplane_ips, local.worker_ips)

  # First control plane node (used for bootstrap)
  first_controlplane_key = keys(var.controlplane_nodes)[0]
  first_controlplane_ip  = var.controlplane_nodes[local.first_controlplane_key].ip

  #----------------------------------------------------------------------------
  # Network Configuration
  #----------------------------------------------------------------------------
  cluster_network_config = {
    network = {
      cni = {
        name = "none"
      }
      podSubnets     = var.talos_config.pod_subnets
      serviceSubnets = var.talos_config.service_subnets
    }
  }

  dns_servers_list = [var.dns_servers.primary, var.dns_servers.secondary]

  #----------------------------------------------------------------------------
  # Encryption Passphrase (for static key mode)
  #----------------------------------------------------------------------------
  encryption_passphrase = try(
    var.encryption.static_key != "" ? var.encryption.static_key : random_password.encryption_key[0].result,
    ""
  )

  #----------------------------------------------------------------------------
  # Base Machine Configurations
  #----------------------------------------------------------------------------
  base_machine_config = {
    sysctls = {
      "vm.nr_hugepages" = var.talos_config.hugepages
    }
    kernel = {
      modules = var.talos_config.kernel_modules
    }
    files = [
      {
        path    = "/etc/cri/conf.d/20-customization.part"
        op      = "create"
        content = <<-EOT
          [plugins."io.containerd.cri.v1.images"]
            discard_unpacked_layers = false
          [plugins."io.containerd.cri.v1.runtime"]
            device_ownership_from_security_context = true
        EOT
      }
    ]
    time = {
      servers = var.talos_config.ntp_servers
    }
  }

  base_kubelet_config = {
    extraArgs = {
      "rotate-server-certificates" = "true"
    }
    clusterDNS = var.talos_config.cluster_dns
  }

  #----------------------------------------------------------------------------
  # Control Plane Machine Configuration (base - no encryption)
  #----------------------------------------------------------------------------
  controlplane_machine_config = {
    machine = {
      sysctls = local.base_machine_config.sysctls
      kernel  = local.base_machine_config.kernel
      files   = local.base_machine_config.files
      time    = local.base_machine_config.time
      kubelet = merge(local.base_kubelet_config, {
        extraMounts = [
          {
            destination = var.cluster.storage_disk
            type        = "bind"
            source      = var.cluster.storage_disk
            options     = ["rbind", "rshared", "rw"]
          }
        ]
      })
      disks = [
        {
          device = "/dev/vdb"
          partitions = [
            {
              mountpoint = var.cluster.storage_disk
            }
          ]
        }
      ]
      install = {
        disk            = var.cluster.install_disk
        image           = talos_image_factory_schematic.controlplane.id
        extraKernelArgs = var.talos_config.extra_kernel_args
      }
    }
  }

  #----------------------------------------------------------------------------
  # Control Plane Cluster Configuration
  #----------------------------------------------------------------------------
  controlplane_cluster_config = {
    cluster = merge(local.cluster_network_config, {
      apiServer = {
        auditPolicy = {
          apiVersion = "audit.k8s.io/v1"
          kind       = "Policy"
          rules      = [{ level = var.security_config.audit_log_level }]
        }
        admissionControl = var.security_config.enable_pod_security_admission ? [
          {
            name = "PodSecurity"
            configuration = {
              apiVersion = "pod-security.admission.config.k8s.io/v1beta1"
              kind       = "PodSecurityConfiguration"
              exemptions = {
                namespaces = var.security_config.psa_exempt_namespaces
              }
            }
          }
        ] : []
      }
      proxy = {
        disabled = true
      }
      extraManifests = [
        "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml",
        "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml",
        "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/experimental-install.yaml"
      ]
      inlineManifests = [
        {
          name = "namespace-flux"
          contents = yamlencode({
            apiVersion = "v1"
            kind       = "Namespace"
            metadata = {
              name = "flux-system"
            }
          })
        },
        {
          name = "namespace-monitoring"
          contents = yamlencode({
            apiVersion = "v1"
            kind       = "Namespace"
            metadata = {
              name = "monitoring"
              labels = {
                "app" = "monitoring"
              }
            }
          })
        },
        {
          name = "namespace-networking"
          contents = yamlencode({
            apiVersion = "v1"
            kind       = "Namespace"
            metadata = {
              name = var.cilium_config.namespace
              labels = {
                "pod-security.kubernetes.io/enforce" = "privileged"
                "pod-security.kubernetes.io/audit"   = "privileged"
                "pod-security.kubernetes.io/warn"    = "privileged"
                "app"                                = "networking"
              }
            }
          })
        },
        {
          name = "namespace-storage"
          contents = yamlencode({
            apiVersion = "v1"
            kind       = "Namespace"
            metadata = {
              name = "storage"
              labels = {
                "pod-security.kubernetes.io/enforce" = "privileged"
                "app"                                = "storage"
              }
            }
          })
        }
      ]
    })
  }

  #----------------------------------------------------------------------------
  # Worker Machine Configuration (base - no encryption)
  #----------------------------------------------------------------------------
  worker_machine_config = {
    machine = {
      sysctls = local.base_machine_config.sysctls
      kernel  = local.base_machine_config.kernel
      files   = local.base_machine_config.files
      time    = local.base_machine_config.time
      kubelet = merge(local.base_kubelet_config, {
        extraMounts = [
          {
            destination = var.cluster.storage_disk_1
            type        = "bind"
            source      = var.cluster.storage_disk_1
            options     = ["rbind", "rshared", "rw"]
          },
          {
            destination = var.cluster.storage_disk_2
            type        = "bind"
            source      = var.cluster.storage_disk_2
            options     = ["rbind", "rshared", "rw"]
          }
        ]
      })
      disks = [
        {
          device = "/dev/vdb"
          partitions = [
            {
              mountpoint = var.cluster.storage_disk_1
            }
          ]
        },
        {
          device = "/dev/vdc"
          partitions = [
            {
              mountpoint = var.cluster.storage_disk_2
            }
          ]
        }
      ]
      install = {
        disk            = var.cluster.install_disk
        image           = talos_image_factory_schematic.worker.id
        extraKernelArgs = var.talos_config.extra_kernel_args
      }
    }
  }

  #----------------------------------------------------------------------------
  # Encryption Config Patches (separate YAML patches for encryption)
  # These are applied as additional config patches when encryption is enabled
  #----------------------------------------------------------------------------
  
  # TPM encryption patch for control plane
  controlplane_encryption_patch_tpm = yamlencode({
    machine = {
      systemDiskEncryption = {
        ephemeral = {
          provider = "luks2"
          keys = [{
            slot = 0
            tpm  = {}
          }]
        }
      }
      disks = [{
        device = "/dev/vdb"
        partitions = [{
          mountpoint = var.cluster.storage_disk
          encryption = {
            provider = "luks2"
            keys = [{
              slot = 0
              tpm  = {}
            }]
          }
        }]
      }]
    }
  })

  # Static key encryption patch for control plane
  controlplane_encryption_patch_static = yamlencode({
    machine = {
      disks = [{
        device = "/dev/vdb"
        partitions = [{
          mountpoint = var.cluster.storage_disk
          encryption = {
            provider = "luks2"
            keys = [{
              slot = 0
              static = {
                passphrase = local.encryption_passphrase
              }
            }]
          }
        }]
      }]
    }
  })

  # TPM encryption patch for workers
  worker_encryption_patch_tpm = yamlencode({
    machine = {
      systemDiskEncryption = {
        ephemeral = {
          provider = "luks2"
          keys = [{
            slot = 0
            tpm  = {}
          }]
        }
      }
      disks = [
        {
          device = "/dev/vdb"
          partitions = [{
            mountpoint = var.cluster.storage_disk_1
            encryption = {
              provider = "luks2"
              keys = [{
                slot = 0
                tpm  = {}
              }]
            }
          }]
        },
        {
          device = "/dev/vdc"
          partitions = [{
            mountpoint = var.cluster.storage_disk_2
            encryption = {
              provider = "luks2"
              keys = [{
                slot = 0
                tpm  = {}
              }]
            }
          }]
        }
      ]
    }
  })

  # Static key encryption patch for workers
  worker_encryption_patch_static = yamlencode({
    machine = {
      disks = [
        {
          device = "/dev/vdb"
          partitions = [{
            mountpoint = var.cluster.storage_disk_1
            encryption = {
              provider = "luks2"
              keys = [{
                slot = 0
                static = {
                  passphrase = local.encryption_passphrase
                }
              }]
            }
          }]
        },
        {
          device = "/dev/vdc"
          partitions = [{
            mountpoint = var.cluster.storage_disk_2
            encryption = {
              provider = "luks2"
              keys = [{
                slot = 0
                static = {
                  passphrase = local.encryption_passphrase
                }
              }]
            }
          }]
        }
      ]
    }
  })

  #----------------------------------------------------------------------------
  # Per-Node Control Plane Configs
  #----------------------------------------------------------------------------
  controlplane_configs = {
    for k, v in var.controlplane_nodes : k => merge(
      local.controlplane_machine_config,
      {
        machine = merge(
          local.controlplane_machine_config.machine,
          {
            network = {
              interfaces = [
                {
                  interface = "eth0"
                  dhcp      = false
                  vip = {
                    ip = var.cluster.vip_ip
                  }
                }
              ]
              hostname    = "${var.environment}-${var.cluster.name}-cp-${random_id.controlplane[k].hex}"
              nameservers = local.dns_servers_list
            }
          }
        )
      },
      local.controlplane_cluster_config,
      {
        cluster = merge(
          local.controlplane_cluster_config.cluster,
          {
            allowSchedulingOnControlPlanes = v.allow_scheduling
          }
        )
      }
    )
  }

  #----------------------------------------------------------------------------
  # Per-Node Worker Configs
  #----------------------------------------------------------------------------
  worker_configs = {
    for k, v in var.worker_nodes : k => merge(
      local.worker_machine_config,
      {
        machine = merge(
          local.worker_machine_config.machine,
          {
            network = {
              hostname    = "${var.environment}-${var.cluster.name}-wk-${random_id.worker[k].hex}"
              nameservers = local.dns_servers_list
              interfaces = [
                {
                  interface = "eth0"
                  dhcp      = false
                }
              ]
            }
            nodeLabels = v.node_labels
          }
        )
      },
      { cluster = local.cluster_network_config }
    )
  }

  #----------------------------------------------------------------------------
  # Cilium Configuration
  #----------------------------------------------------------------------------
  cilium_lb_pool_start = cidrhost(var.cilium_config.node_network, var.cilium_config.load_balancer_start)
  cilium_lb_pool_stop  = cidrhost(var.cilium_config.node_network, var.cilium_config.load_balancer_stop)
}
