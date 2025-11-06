# ========================================
# BACKUP AUTOMÁTICO - S3 + SNS
# Compatível com AWS Academy (LabRole)
# ========================================

# Bucket S3 para armazenar backups do banco de dados
resource "aws_s3_bucket" "backup_mysql" {
  bucket = "capacita-mysql-backups-${var.projeto}"

  tags = {
    Name        = "capacita-mysql-backups"
    Environment = var.ambiente
    Projeto     = var.projeto
    ManagedBy   = "Terraform"
  }
}

# Versionamento habilitado (recuperar backups antigos)
resource "aws_s3_bucket_versioning" "backup_mysql_versioning" {
  bucket = aws_s3_bucket.backup_mysql.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Criptografia no bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "backup_mysql_encryption" {
  bucket = aws_s3_bucket.backup_mysql.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Política de ciclo de vida (manter backups por 30 dias)
resource "aws_s3_bucket_lifecycle_configuration" "backup_mysql_lifecycle" {
  bucket = aws_s3_bucket.backup_mysql.id

  rule {
    id     = "backup-lifecycle"
    status = "Enabled"

    # Filter vazio aplica a regra para todos os objetos
    filter {}

    # Após 30 dias, deletar backups antigos
    expiration {
      days = 30
    }

    # Limpar versões antigas após 7 dias
    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

# Bloquear acesso público
resource "aws_s3_bucket_public_access_block" "backup_mysql_block" {
  bucket = aws_s3_bucket.backup_mysql.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ========================================
# SNS TOPIC PARA NOTIFICAÇÕES DE BACKUP
# ========================================

resource "aws_sns_topic" "backup_notifications" {
  name = "capacita-backup-notifications"

  tags = {
    Name      = "capacita-backup-notifications"
    Projeto   = var.projeto
    ManagedBy = "Terraform"
  }
}

# Subscription por email (ALTERE para o email do admin)
resource "aws_sns_topic_subscription" "backup_email" {
  topic_arn = aws_sns_topic.backup_notifications.arn
  protocol  = "email"
  endpoint  = var.admin_email # Defina essa variável no terraform.tfvars
}

# ========================================
# NOTA: AWS Academy usa LabRole automaticamente
# Não é necessário criar IAM roles/policies adicionais
# O LabRole já tem permissões para S3 e SNS
# ========================================

# ========================================
# OUTPUTS
# ========================================

output "backup_bucket_name" {
  description = "Nome do bucket S3 para backups"
  value       = aws_s3_bucket.backup_mysql.id
}

output "sns_topic_arn" {
  description = "ARN do tópico SNS para notificações de backup"
  value       = aws_sns_topic.backup_notifications.arn
}

output "backup_bucket_arn" {
  description = "ARN do bucket de backups"
  value       = aws_s3_bucket.backup_mysql.arn
}
