resource "kubernetes_secret" "aws_secret" {
  metadata {
    name      = "${var.env}-${var.app}-secret"
    namespace = var.app
  }
  data = {
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.key.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.key.secret
    AWS_ROLE_ARN          = aws_iam_role.backup_role.arn
    BUCKET                = aws_s3_bucket.db_backup.id
  }
}
