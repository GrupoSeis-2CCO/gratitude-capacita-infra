// IAM role, policy e instance profile para backups (S3 upload + SES send)

resource "aws_iam_role" "backup_role" {
  count = var.lab_role_arn == "" ? 1 : 0
  name  = "gratitude-backup-role-${random_string.bucket_aleatorio.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "backup_policy" {
  count       = var.lab_role_arn == "" ? 1 : 0
  name        = "gratitude-backup-policy-${random_string.bucket_aleatorio.result}"
  description = "Permite upload de backups para o bucket e enviar emails via SNS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          var.backup_bucket_name != "" ? "arn:aws:s3:::${var.backup_bucket_name}" : aws_s3_bucket.db_backups[0].arn,
          var.backup_bucket_name != "" ? "arn:aws:s3:::${var.backup_bucket_name}/*" : "${aws_s3_bucket.db_backups[0].arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = [
          aws_sns_topic.backup_notifications.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backup_attach" {
  count      = var.lab_role_arn == "" ? 1 : 0
  role       = aws_iam_role.backup_role[0].name
  policy_arn = aws_iam_policy.backup_policy[0].arn
}

resource "aws_iam_instance_profile" "backup_profile" {
  count = var.lab_role_arn == "" && var.instance_profile_name == "" ? 1 : 0
  name  = "gratitude-backup-profile-${random_string.bucket_aleatorio.result}"
  role  = aws_iam_role.backup_role[0].name
}
