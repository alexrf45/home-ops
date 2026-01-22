data "helm_template" "this" {
  name       = "cilium"
  namespace  = var.cilium_config.namespace
  repository = "https://helm.cilium.io/"

  chart        = "cilium"
  version      = var.cilium_config.cilium_version
  kube_version = var.cilium_config.kube_version
  include_crds = true

  values = [
    yamlencode({
      resources = {
        limits = {
          cpu    = "1000m"
          memory = "250Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "100Mi"
        }
      }

      ipam = {
        mode = "kubernetes"
      }

      kubeProxyReplacement = true
      enableIPv6Masquerade = false
      dnsPolicy            = "ClusterFirst"

      encryption = {
        enabled        = true
        nodeEncryption = true
        type           = "wireguard"
        wireguard = {
          persistentKeepalive = "0s"
        }
      }

      l2announcements = {
        enabled = true
      }

      securityContext = {
        capabilities = {
          cleanCiliumState = ["NET_ADMIN", "SYS_ADMIN", "SYS_RESOURCE"]
          ciliumAgent      = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
        }
      }
      hubble = {
        enabled           = var.cilium_config.hubble_enabled
        enableOpenMetrics = false
        metrics = {
          enabled = ["dns:query", "drop", "tcp", "flow", "port-distribution", "icmp", "http"]
        }
        relay = {
          enabled     = var.cilium_config.relay_enabled
          rollOutPods = var.cilium_config.relay_pods_rollout
        }
        ui = {
          enabled = var.cilium_config.hubble_ui_enabled
        }
      }

      cgroup = {
        autoMount = {
          enabled = false
        }
        hostRoot = "/sys/fs/cgroup"
      }

      k8sServiceHost = "localhost"
      k8sServicePort = "7445"

      ingressController = {
        default          = var.cilium_config.ingress_default_controller
        enabled          = var.cilium_config.ingress_controller_enabled
        loadbalancerMode = var.cilium_config.load_balancer_mode
        service = {
          externalTrafficPolicy = "Cluster"
          loadBalancerIP        = var.cilium_config.load_balancer_ip
          name                  = "cilium-ingress"
          type                  = "LoadBalancer"
        }
      }

      gatewayAPI = {
        enabled = var.cilium_config.gateway_api_enabled
        gatewayClass = {
          create = "auto"
        }
      }

      redact = {
        enabled = true
        http = {
          urlQuery = true
          userInfo = true
        }
      }

      externalIPs = {
        enabled = true
      }

      k8sClientRateLimit = {
        qps   = 30
        burst = 50
      }
    })
  ]
}
