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

data "aws_iam_user" "this" {
  user_name = "external-secrets"
}

resource "aws_iam_access_key" "external-secrets" {
  user = data.aws_iam_user.this.user_name
}


# Secret for AWS SM access keys
resource "kubernetes_secret" "awssm_secret" {
  metadata {
    name      = "awssm-secret"
    namespace = "external-secrets"
  }

  data = {
    "access-key"        = base64encode(aws_iam_access_key.external-secrets.id)
    "secret-access-key" = base64encode(aws_iam_access_key.external-secrets.secret)
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

