data "onepassword_vault" "this" {
  name = var.vault_name
}

resource "onepassword_item" "this" {
  depends_on = [aws_iam_access_key.key]
  vault      = data.onepassword_vault.this.uuid

  title    = var.item_id
  category = "login"

  section {
    label = "access_key"

    field {
      label = "accesskey"
      type  = "STRING"
      value = aws_iam_access_key.key.id
    }
    field {
      label = "secretkey"
      type  = "STRING"
      value = aws_iam_access_key.key.secret
    }
    field {
      label = "BUCKET"
      type  = "STRING"
      value = aws_s3_bucket.this.id
    }
    field {
      label = "iam_role_arn"
      type  = "STRING"
      value = aws_iam_role.backup_role.arn
    }

  }

  tags = ["${var.env}", "${var.app}"]
}
