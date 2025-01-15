resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "kubernetes_namespace" "storage" {
  metadata {
    name = "storage"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}
