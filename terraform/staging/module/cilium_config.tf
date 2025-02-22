data "helm_template" "cilium_template" {
  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"

  chart        = "cilium"
  version      = "1.17.0-rc.2"
  kube_version = "1.32.0"

  include_crds = true

  values = [<<-EOF
    ipam:
      mode: kubernetes

    kubeProxyReplacement: true

    enableIPv6Masquerade: false

    dnsPolicy: "ClusterFirst"
    encryption:
      enabled: true
      nodeEncryption: true
      type: wireguard
      wireguard:
        persistentKeepalive: 0s

    l2announcements:
      enabled: true

    securityContext:
      capabilities:
        cleanCiliumState:
          - NET_ADMIN
          - SYS_ADMIN
          - SYS_RESOURCE
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

    ingressController:
      default: true
      enabled: true
      loadbalancerMode: shared
      service:
        annotations:
          cert-manager.io/cluster-issuer: letsencrypt-staging
        externalTrafficPolicy: Cluster
        loadBalancerIP: 10.3.3.70
        name: cilium-ingress
        type: LoadBalancer
    gatewayAPI:
      enabled: true
      gatewayClass:
        create: auto
    redact:
      enabled: true
      http:
        urlQuery: true
        userInfo: true
    externalIPs:
      enabled: true
    k8sClientRateLimit:
      qps: 15
      burst: 20
  EOF

  ]
}
