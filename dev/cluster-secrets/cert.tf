resource "kubernetes_manifest" "clusterissuer_kube_system_letsencrypt_staging" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-staging"
    }
    "spec" = {
      "acme" = {
        "email" = "k3s@f0nzy.com"
        "privateKeySecretRef" = {
          "name" = "letsencrypt-staging"
        }
        "server" = "https://acme-staging-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "dns01" = {
              "cloudflare" = {
                "apiTokenSecretRef" = {
                  "key"  = "cloudflare-token"
                  "name" = "cloudflare-token-secret"
                }
                "email" = "cloudflare@f0nzy.com"
              }
            }
            "selector" = {
              "dnsZones" = [
                "fr3d.dev",
              ]
            }
          },
        ]
      }
    }
  }
}
