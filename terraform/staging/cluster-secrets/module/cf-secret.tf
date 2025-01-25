# Secret for Cloudflare DNS w/ cert manager
resource "kubernetes_secret" "cf-dns" {
  metadata {
    name      = "cloudflare-token-secret"
    namespace = "cert-manager"
  }

  data = {
    "cloudflare-token" = var.token
  }

  type = "Opaque"
}
