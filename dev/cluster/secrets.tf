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
    # Populate this map dynamically with the contents of .pihole.env
    for key, value in tomap(file("${path.module}/secrets-folder/.pihole.env"))
    : key => base64encode(value)
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
    "access-key"        = base64encode(file("${path.module}/secrets-folder/access-key"))
    "secret-access-key" = base64encode(file("${path.module}/secrets-folder/secret-access-key"))
  }

  type = "Opaque"
}

resource "kubernetes_secret" "basic_auth" {
  metadata {
    name      = "basic-auth"
    namespace = "storage"
  }
  data = {
    username = base64encode(var.username)
    password = base64encode(random_string.pihole-password.result)
  }
}

