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
resource "aws_s3_bucket" "imagens" {
  bucket = "gratitude-imagens-frontend"
  force_destroy = true
  tags = {
    Name = "gratitude-imagens"
  }
}

# ====================================
# BUCKETS DO PIPELINE DE DADOS
# ====================================

# Bucket Bronze - dados originais CSV
resource "aws_s3_bucket" "bronze_bucket" {
  bucket        = "gratitude-capacita-bronze-nov26"
  force_destroy = true

  tags = {
    Name        = "Bronze Data Lake"
    Environment = var.environment
    Purpose     = "Raw CSV data storage"
  }
}

# Bucket Silver - One Big Table
resource "aws_s3_bucket" "silver_bucket" {
  bucket        = "gratitude-capacita-silver-nov26"
  force_destroy = true

  tags = {
    Name        = "Silver Data Lake"
    Environment = var.environment
    Purpose     = "Processed unified table"
  }
}

# Bucket Gold - Tabelas Grafana
resource "aws_s3_bucket" "gold_bucket" {
  bucket        = "gratitude-capacita-gold-nov26"
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
