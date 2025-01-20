resource "kubernetes_namespace" "external-secrets" {
  metadata {
    annotations = {
      name = "external-secrets"
    }
    name = "external-secrets"
    labels = {
      app = "eso"
      env = var.env
    }

  }
}
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      app                                  = "prometheus"
      env                                  = var.env
    }
  }
}

resource "kubernetes_namespace" "storage" {
  metadata {
    name = "storage"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      app                                  = "longhorn"
      env                                  = var.env
    }
  }
}


resource "kubernetes_namespace" "argo-cd" {
  metadata {
    annotations = {
      name = "argo-cd"
    }

    labels = {
      app = "argo-cd"
      env = var.env
    }
    name = "argo-cd"
  }
}


resource "kubernetes_namespace" "pihole-system" {
  metadata {
    annotations = {
      name = "pihole-system"
    }

    labels = {
      app = "pihole"
      env = var.env
    }
    name = "pihole-system"
  }
}
resource "kubernetes_namespace" "nginx-system" {
  metadata {
    annotations = {
      name = "nginx-system"
    }

    labels = {
      app = "nginx-ingress-controller"
      env = var.env
    }
    name = "nginx-system"
  }
}
