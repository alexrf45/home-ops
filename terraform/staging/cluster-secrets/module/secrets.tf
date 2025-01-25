resource "random_string" "pihole-password" {
  length      = 35
  min_upper   = 3
  min_lower   = 3
  min_numeric = 4
  min_special = 6
}

# Secret for Pi-hole password
resource "kubernetes_secret" "pihole_password" {
  metadata {
    name      = "pihole-password"
    namespace = "pihole-system"
  }
  data = {
    username = var.username
    password = random_string.pihole-password.result
  }

  type = "Opaque"
}


# Secret for AWS SM access keys
resource "kubernetes_secret" "awssm_secret" {
  metadata {
    name      = "awssm-secret"
    namespace = "external-secrets"
  }

  data = {
    "access-key"        = base64encode(var.access-key-id)
    "secret-access-key" = base64encode(var.secret-access-key)
  }

  type = "Opaque"
}


resource "random_string" "grafana-password" {
  length      = 35
  min_upper   = 3
  min_lower   = 3
  min_numeric = 4
  min_special = 6
}

resource "kubernetes_secret" "grafana" {
  metadata {
    name      = "grafana-secret"
    namespace = "monitoring"
  }
  data = {
    admin-user     = base64encode(var.username)
    admin-password = base64encode(random_string.grafana-password.result)
  }
}
