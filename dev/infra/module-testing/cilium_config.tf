data "helm_template" "cilium_template" {
  name             = "cilium"
  create_namespace = true
  repository       = "https://helm.cilium.io/"

  chart        = "cilium"
  version      = "1.16.5"
  kube_version = "1.32.0"

  include_crds = true

  values = [<<-EOF
    ipam:
      mode: kubernetes
    kubeProxyReplacement: true
    
    l2announcements:
      enabled: true
    l7Proxy: false

    securityContext:
      privileged: true
      capabilities:
        cleanCiliumState:
          - NET_ADMIN
          - SYS_ADMIN
          - SYS_RESOURCE2
        ciliumAgent:
          - CHOWN
          - KILL
          - NET_ADMIN
          - NET_RAW
          - IPC_LOCK
          - SYS_ADMIN
          - SYS_RESOURCE
          - DAC_OVERRIDE
          - FOWNER
          - SETGID
          - SETUID

    hubble:
      enabled: true
      metrics:
        enabled:
          - dns:query
          - drop
          - tcp
          - flow
          - port-distribution
          - icmp
          - http
      relay:
        enabled: true
        rollOutPods: true
      ui:
        enabled: true

    cgroup:
      autoMount:
        enabled: false
      hostRoot: /sys/fs/cgroup

    k8sServiceHost: localhost
    k8sServicePort: "7445"

    externalIPs:
      enabled: true
  EOF
  ]
}

resource "local_file" "cilium_config" {
  depends_on = [data.helm_template.cilium_template]
  content    = templatefile("${path.module}/templates/cilium-cni-template.yaml", { cilium_yaml = data.helm_template.cilium_template.manifest })
  filename   = "${path.root}/patches/cilium-cni-patch.yaml"
}

