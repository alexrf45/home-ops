resource "kubernetes_namespace" "external-secrets" {
  metadata {
    annotations = {
      name = "external-secrets"
    }

    labels = {
      app = "eso"
      env = var.env
    }

    name = "external-secrets"
  }
}

resource "kubernetes_namespace" "storage" {
  metadata {
    annotations = {
      name = "storage"
    }

    labels = {
      app = "longhorn"
      env = var.env
    }

    name = "storage"
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
      name = "pihole"
    }

    labels = {
      app = "pihole"
      env = var.env
    }

    name = "pihole"
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
resource "kubernetes_namespace" "argo-cd" {
  metadata {
    annotations = {
      name = "argo-cd"
    }

    labels = {
      app = "argo-cd"
      env = "dev"
    }

    name = "argo-cd"
  }
}
resource "kubernetes_namespace" "argo-cd" {
  metadata {
    annotations = {
      name = "argo-cd"
    }

    labels = {
      app = "argo-cd"
      env = "dev"
    }

    name = "argo-cd"
  }
}
