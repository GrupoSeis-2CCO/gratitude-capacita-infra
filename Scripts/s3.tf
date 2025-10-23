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
  bucket = "gratitude-bronze-${random_string.bucket_aleatorio.result}"
  force_destroy = true
  tags = {
    Name = "gratitude-bronze"
  }
}

resource "aws_s3_bucket" "silver" {
  bucket = "gratitude-silver-${random_string.bucket_aleatorio.result}"
  force_destroy = true
  tags = {
    Name = "gratitude-silver"
  }
}

resource "aws_s3_bucket" "gold" {
  bucket = "gratitude-gold-${random_string.bucket_aleatorio.result}"
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
