resource "kubernetes_manifest" "secret_kube_system_cloudflare_token_secret" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "cloudflare-token" = var.token
    }
    "kind" = "Secret"
    "metadata" = {
      "creationTimestamp" = null
      "name"              = "cloudflare-token-secret"
      "namespace"         = "kube-system"
    }
  }
}
