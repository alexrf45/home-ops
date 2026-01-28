resource "talos_machine_secrets" "this" {
  talos_version = var.talos.version
}

data "talos_client_configuration" "this" {
  cluster_name         = var.talos.name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes = [
    for k, v in merge(var.worker_nodes, var.controlplane_nodes) : v.ip
  ]
  endpoints = [for k, v in var.controlplane_nodes : v.ip]
}

#############################
# Control Plane Configuration
#############################
data "talos_machine_configuration" "controlplane" {
  for_each         = var.controlplane_nodes
  cluster_name     = var.talos.name
  cluster_endpoint = "https://${var.talos.endpoint}:6443"
  talos_version    = var.talos.version
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [
    <<-EOT
    machine:
      systemDiskEncryption:
        ephemeral:
          provider: luks2
          keys:
            - nodeID: {}
              slot: 0
              tpm: {}
        state:
          provider: luks2
          keys:
            - nodeID: {}
              slot: 0
              tpm: {}
      sysctls:
        vm.nr_hugepages: "1024"
      kernel:
        modules:
          - name: nvme_tcp
          - name: vfio_pci
      files:
        - path: /etc/cri/conf.d/20-customization.part
          op: create
          content: |
            [plugins."io.containerd.cri.v1.images"]
              discard_unpacked_layers = false
            [plugins."io.containerd.cri.v1.runtime"]
              device_ownership_from_security_context = true
      time:
        servers:
          - time.cloudflare.com
      kubelet:
        extraArgs:
          rotate-server-certificates: true
        clusterDNS:
          - 10.43.0.10
        extraMounts:
          - destination: ${var.talos.storage_disk}
            type: bind
            source: ${var.talos.storage_disk}
            options:
              - rbind
              - rshared
              - rw
      disks:
        - device: /dev/vdb
          partitions:
            - mountpoint: ${var.talos.storage_disk}
      install:
        disk: ${var.talos.install_disk}
        image: ${data.talos_image_factory_urls.controlplane.urls.installer}
        wipe: true
        extraKernelArgs:
          - console=ttyS1
          - panic=10
          - cpufreq.default_governor=performance
          - intel_idle.max_cstate=0
          - disable_ipv6=1
      network:
        interfaces:
          - interface: eth0
            dhcp: false
            vip:
              ip: ${var.talos.vip_ip}
        nameservers:
          - ${var.nameservers.primary}
          - ${var.nameservers.secondary}
    cluster:
      apiServer:
        auditPolicy:
          apiVersion: audit.k8s.io/v1
          kind: Policy
          rules:
            - level: Metadata
        admissionControl:
          - name: PodSecurity
            configuration:
              apiVersion: pod-security.admission.config.k8s.io/v1beta1
              kind: PodSecurityConfiguration
              exemptions:
                namespaces:
                  - networking
                  - storage
      network:
        cni:
          name: none
        podSubnets:
          - 10.42.0.0/16
        serviceSubnets:
          - 10.43.0.0/16
      proxy:
        disabled: true
      extraManifests:
        - https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml
        - https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
        - https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml
      inlineManifests:
        - name: namespace-flux
          contents: |
            apiVersion: v1
            kind: Namespace
            metadata:
              name: flux-system
        - name: namespace-networking
          contents: |
            apiVersion: v1
            kind: Namespace
            metadata:
              name: networking
              labels:
                pod-security.kubernetes.io/enforce: "privileged"
                app: "networking"
        - name: namespace-storage
          contents: |
            apiVersion: v1
            kind: Namespace
            metadata:
              name: storage
              labels:
                pod-security.kubernetes.io/enforce: "privileged"
                app: "storage"
    EOT
    ,
    # Cilium inline manifest handled separately to avoid YAML formatting issues
    yamlencode({
      cluster = {
        inlineManifests = [
          {
            name = "cilium"
            contents = join("---\n", [
              data.helm_template.this.manifest,
              "# Source cilium.tf\n${local.cilium_lb_manifest}",
            ])
          }
        ]
      }
    }),
  ]
}

#############################
# Worker Node Configuration
#############################
data "talos_machine_configuration" "worker" {
  for_each         = var.worker_nodes
  cluster_name     = var.talos.name
  cluster_endpoint = "https://${var.talos.endpoint}:6443"
  talos_version    = var.talos.version
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [
    <<-EOT
    version: v1alpha1
    cluster:
      network:
        podSubnets:
          - 10.42.0.0/16
        serviceSubnets:
          - 10.43.0.0/16
    machine:
      systemDiskEncryption:
        ephemeral:
          provider: luks2
          keys:
            - nodeID: {}
              slot: 0
              tpm: {}
        state:
          provider: luks2
          keys:
            - nodeID: {}
              slot: 0
              tpm: {}
      sysctls:
        vm.nr_hugepages: "1024"
      kernel:
        modules:
          - name: nvme_tcp
          - name: vfio_pci
      files:
        - path: /etc/cri/conf.d/20-customization.part
          op: create
          content: |
            [plugins."io.containerd.cri.v1.images"]
              discard_unpacked_layers = false
            [plugins."io.containerd.cri.v1.runtime"]
              device_ownership_from_security_context = true
      time:
        servers:
          - time.cloudflare.com
      kubelet:
        extraArgs:
          rotate-server-certificates: true
        clusterDNS:
          - 10.43.0.10
        extraMounts:
          - destination: ${var.talos.storage_disk}
            type: bind
            source: ${var.talos.storage_disk}
            options:
              - rbind
              - rshared
              - rw
      disks:
        - device: /dev/vdb
          partitions:
            - mountpoint: ${var.talos.storage_disk}
      install:
        disk: ${var.talos.install_disk}
        image: ${data.talos_image_factory_urls.worker.urls.installer}
        wipe: true
        extraKernelArgs:
          - console=ttyS1
          - panic=10
          - cpufreq.default_governor=performance
          - intel_idle.max_cstate=0
          - disable_ipv6=1
      network:
        nameservers:
          - ${var.nameservers.primary}
          - ${var.nameservers.secondary}
        interfaces:
          - interface: eth0
            dhcp: false
    EOT
  ]
}

#############################
# Apply Configurations
#############################
resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [
    proxmox_virtual_environment_vm.controlplane,
    data.talos_machine_configuration.controlplane,
  ]
  apply_mode = "auto"
  for_each   = var.controlplane_nodes
  node       = each.value.ip

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane[each.key].machine_configuration

  config_patches = [
    <<-EOT
    ---
    apiVersion: v1alpha1
    kind: HostnameConfig
    auto: off
    hostname: ${var.env}-${var.talos.name}-cp-${random_id.this[each.key].hex}
    ---
    version: v1alpha1
    cluster:
      allowSchedulingOnControlPlanes: ${each.value.allow_scheduling}
    EOT
  ]

  timeouts = {
    create = "5m"
  }
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_vm.controlplane[each.key]]
  }
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on = [
    proxmox_virtual_environment_vm.worker,
    data.talos_machine_configuration.worker,
    talos_machine_configuration_apply.controlplane
  ]
  apply_mode = "auto"
  for_each   = var.worker_nodes
  node       = each.value.ip

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[each.key].machine_configuration
  config_patches = [
    <<-EOT
    ---
    apiVersion: v1alpha1
    kind: HostnameConfig
    auto: off
    hostname: ${var.env}-${var.talos.name}-node-${random_id.this[each.key].hex}
    EOT
  ]
  timeouts = {
    create = "5m"
  }
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_vm.worker[each.key]]
  }
}

#############################
# Bootstrap & Kubeconfig
#############################
resource "time_sleep" "wait_until_apply" {
  depends_on = [
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker
  ]
  create_duration = "30s"
}

resource "talos_machine_bootstrap" "this" {
  count = var.bootstrap_cluster ? 1 : 0
  depends_on = [
    time_sleep.wait_until_apply,
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker
  ]
  node                 = var.talos.endpoint
  endpoint             = var.talos.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration
  timeouts = {
    create = "3m"
  }
}

resource "time_sleep" "wait_until_bootstrap" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  create_duration = "30s"
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    time_sleep.wait_until_bootstrap
  ]
  node                 = var.talos.endpoint
  endpoint             = var.talos.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration
  timeouts = {
    read   = "1m"
    create = "5m"
  }
}
