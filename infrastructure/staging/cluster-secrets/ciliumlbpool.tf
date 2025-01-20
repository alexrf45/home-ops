resource "kubernetes_manifest" "ciliumloadbalancerippool_dev_pool" {
  manifest = {
    "apiVersion" = "cilium.io/v2alpha1"
    "kind" = "CiliumLoadBalancerIPPool"
    "metadata" = {
      "name" = "dev-pool"
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
      "disabled" = false
    }
  }
}
