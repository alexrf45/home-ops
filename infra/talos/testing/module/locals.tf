# locals.tf
locals {
  # Generate IP addresses for nodes
  control_plane_ips = [
    for i in range(var.node_config.control_plane_count) :
    cidrhost("${var.node_config.base_ip}/24", i)
  ]

  worker_ips = [
    for i in range(var.node_config.worker_count) :
    cidrhost("${var.node_config.base_ip}/24", i + var.node_config.control_plane_count)
  ]

  # All node IPs combined
  all_node_ips = concat(local.control_plane_ips, local.worker_ips)

  # Cilium load balancer manifests
  cilium_external_lb_manifests = [
    {
      apiVersion = "cilium.io/v2alpha1"
      kind       = "CiliumL2AnnouncementPolicy"
      metadata = {
        name = "external"
      }
      spec = {
        loadBalancerIPs = true
        interfaces      = ["eth0"]
        nodeSelector = {
          matchExpressions = [
            {
              key      = "node-role.kubernetes.io/control-plane"
              operator = "DoesNotExist"
            },
          ]
        }
      }
    },
    {
      apiVersion = "cilium.io/v2alpha1"
      kind       = "CiliumLoadBalancerIPPool"
      metadata = {
        name = "external"
      }
      spec = {
        blocks = [
          {
            start = cidrhost(var.cluster.node_network, var.cilium_config.load_balancer_start)
            stop  = cidrhost(var.cluster.node_network, var.cilium_config.load_balancer_stop)
          },
        ]
      }
    },
  ]
  cilium_lb_manifest = join("---\n", [for d in local.cilium_external_lb_manifests : yamlencode(d)])
}
