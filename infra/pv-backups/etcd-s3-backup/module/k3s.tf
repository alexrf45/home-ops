resource "kubernetes_secret" "aws_secret" {
  metadata {
    name      = "aws-etcd-secret"
    namespace = var.app
  }
  data = {
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.key.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.key.secret
    AWS_ROLE_ARN          = aws_iam_role.backup_role.arn
  }
}

resource "kubernetes_secret" "aws_secret_temp" {
  metadata {
    name      = "aws-etcd-secret"
    namespace = "kube-system"
  }
  data = {
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.key.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.key.secret
    AWS_ROLE_ARN          = aws_iam_role.backup_role.arn
  }
}
