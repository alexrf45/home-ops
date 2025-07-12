

data "aws_iam_policy_document" "s3-iam" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::${var.env}-${var.app}-${random_uuid.test.result}",
      "arn:aws:s3:::${var.env}-${var.app}-${random_uuid.test.result}/*",
    ]
  }
}

resource "aws_iam_role_policy" "db_role" {
  name   = "${var.env}-${var.app}-role-policy"
  role   = aws_iam_role.backup_role.id
  policy = data.aws_iam_policy_document.s3-iam.json
}


resource "aws_iam_role" "backup_role" {
  name = "${var.env}-${var.app}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = aws_iam_user.user.arn
        }
      },
    ]
  })
}

# Create the IAM user
resource "aws_iam_user" "user" {
  name = var.username
  path = var.path

  tags = {
    Environment = var.env
    Application = var.app
    Owner       = var.username
  }
}
resource "aws_iam_user_policy" "policy" {
  name   = "${var.env}-${var.app}-user-policy"
  user   = aws_iam_user.user.name
  policy = data.aws_iam_policy_document.s3-iam.json
}

# resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
#   user       = aws_iam_user.user.name
#   policy_arn = aws_iam_user_policy.policy.arn
# }

resource "aws_iam_access_key" "key" {
  user = aws_iam_user.user.name
}
