resource "kubernetes_manifest" "ciliumloadbalancerippool_internal_pool" {
  manifest = {
    "apiVersion" = "cilium.io/v2alpha1"
    "kind" = "CiliumLoadBalancerIPPool"
    "metadata" = {
      "name" = "internal-pool"
    }
    "spec" = {
      "blocks" = [
        {
          "cidr" = "10.3.3.80/28"
        },
        {
          "cidr" = "10.3.3.96/27"
        },
        {
          "cidr" = "10.3.3.128/27"
        },
        {
          "cidr" = "10.3.3.160/32"
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "ciliuml2announcementpolicy_l2policy" {
  manifest = {
    "apiVersion" = "cilium.io/v2alpha1"
    "kind" = "CiliumL2AnnouncementPolicy"
    "metadata" = {
      "name" = "l2policy"
    }
    "spec" = {
      "externalIPs" = true
      "interfaces" = [
        "eth0",
      ]
      "loadBalancerIPs" = true
    }
  }
}
