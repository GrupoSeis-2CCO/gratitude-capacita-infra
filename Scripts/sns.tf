// SNS topic para notificacoes de backup
resource "aws_sns_topic" "backup_notifications" {
  name = "gratitude-backup-notifications-${random_string.bucket_aleatorio.result}"
}

# Subscription por email (recipient precisa confirmar)
resource "aws_sns_topic_subscription" "admin_email_sub" {
  topic_arn = aws_sns_topic.backup_notifications.arn
  protocol  = "email"
  endpoint  = var.admin_email
}
