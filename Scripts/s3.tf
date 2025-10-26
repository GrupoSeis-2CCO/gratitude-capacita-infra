# ====================================
# S3 BUCKETS
# ====================================

# String aleatória para nomes únicos dos buckets
resource "random_string" "bucket_aleatorio" {
  length  = 8
  special = false
  upper   = false
}

# ====================================
# BUCKETS ORIGINAIS DO PROJETO
# ====================================

# Buckets S3 para Bronze, Silver e Gold
resource "aws_s3_bucket" "bronze" {
  bucket = "gratitude-capacita-bronze"
  force_destroy = true
  tags = {
    Name = "gratitude-bronze"
  }
}

resource "aws_s3_bucket" "silver" {
  bucket = "gratitude-capacita-silver"
  force_destroy = true
  tags = {
    Name = "gratitude-silver"
  }
}

resource "aws_s3_bucket" "gold" {
  bucket = "gratitude-capacita-gold"
  force_destroy = true
  tags = {
    Name = "gratitude-gold"
  }
}

# Bucket para deploy automatico do JAR do backend
resource "aws_s3_bucket" "deploy" {
  bucket = "gratitude-deploy-${random_string.bucket_aleatorio.result}"
  force_destroy = true
  tags = {
    Name = "gratitude-deploy"
  }
}

resource "aws_s3_bucket" "jar_backend" {
  bucket = "gratitude-jar-backend"
  force_destroy = true
  tags = {
    Name = "gratitude-jar-backend"
  }
}

# Bucket para backups do banco de dados
resource "aws_s3_bucket" "db_backups" {
  count         = var.backup_bucket_name == "" ? 1 : 0
  bucket        = "gratitude-db-backups-${random_string.bucket_aleatorio.result}"
  force_destroy = true
  tags = {
    Name        = "DB Backups"
    Environment = var.environment
    Purpose     = "Backups diarios do banco MySQL"
  }
}

// Recursos separados recomendados pela provider para versioning, SSE e lifecycle
resource "aws_s3_bucket_versioning" "db_backups_versioning" {
  count  = var.backup_bucket_name == "" ? 1 : 0
  bucket = aws_s3_bucket.db_backups[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "db_backups_sse" {
  count  = var.backup_bucket_name == "" ? 1 : 0
  bucket = aws_s3_bucket.db_backups[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "db_backups_lifecycle" {
  count  = var.backup_bucket_name == "" ? 1 : 0
  bucket = aws_s3_bucket.db_backups[0].id

  rule {
    id     = "backup-retention"
    status = "Enabled"
    # Aplica a regra a todo o bucket (prefix vazio)
    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    expiration {
      days = 365
    }
  }
}
# ====================================
# BUCKETS DO PIPELINE DE DADOS
# ====================================

# Bucket Bronze - dados originais CSV
resource "aws_s3_bucket" "bronze_bucket" {
  bucket        = "bronze-gratitude-analise-2025"
  force_destroy = true

  tags = {
    Name        = "Bronze Data Lake"
    Environment = var.environment
    Purpose     = "Raw CSV data storage"
  }
}

# Bucket Silver - One Big Table
resource "aws_s3_bucket" "silver_bucket" {
  bucket        = "silver-gratitude-analise-2025"
  force_destroy = true

  tags = {
    Name        = "Silver Data Lake"
    Environment = var.environment
    Purpose     = "Processed unified table"
  }
}

# Bucket Gold - Tabelas Grafana
resource "aws_s3_bucket" "gold_bucket" {
  bucket        = "gold-gratitude-analise-2025"
  force_destroy = true

  tags = {
    Name        = "Gold Data Lake"
    Environment = var.environment
    Purpose     = "Grafana-ready tables"
  }
}

# Pastas no bucket Bronze
resource "aws_s3_object" "bronze_folder" {
  bucket  = aws_s3_bucket.bronze_bucket.id
  key     = "bronze/"
  content = ""
}
