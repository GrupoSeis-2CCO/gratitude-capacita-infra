# ====================================
# S3 BUCKETS
# ====================================

# String aleatória para nomes únicos dos buckets
resource "random_string" "bucket_aleatorio" {
  length  = 8
  special = false
  upper   = false
}

# Buckets S3 para Bronze, Silver e Gold
resource "aws_s3_bucket" "imagens" {
  bucket = "gratitude-imagens-frontend"
  force_destroy = true
  tags = {
    Name = "gratitude-imagens"
  }
}

# Desabilitar bloqueio de acesso público para o bucket de imagens
resource "aws_s3_bucket_public_access_block" "imagens_public_access" {
  bucket = aws_s3_bucket.imagens.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Política de bucket para permitir leitura pública das imagens
resource "aws_s3_bucket_policy" "imagens_policy" {
  bucket = aws_s3_bucket.imagens.id
  depends_on = [aws_s3_bucket_public_access_block.imagens_public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.imagens.arn}/*"
      }
    ]
  })
}

# Configuração CORS para permitir fetch do frontend
resource "aws_s3_bucket_cors_configuration" "imagens_cors" {
  bucket = aws_s3_bucket.imagens.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["Content-Length", "Content-Type"]
    max_age_seconds = 3600
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
# BUCKET PARA APOSTILAS/PDFs
# ====================================

resource "aws_s3_bucket" "apostilas" {
  bucket = "gratitude-apostilas"
  force_destroy = true
  tags = {
    Name = "gratitude-apostilas"
  }
}

# Desabilitar bloqueio de acesso público para o bucket de apostilas
resource "aws_s3_bucket_public_access_block" "apostilas_public_access" {
  bucket = aws_s3_bucket.apostilas.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Política de bucket para permitir leitura pública das apostilas
resource "aws_s3_bucket_policy" "apostilas_policy" {
  bucket = aws_s3_bucket.apostilas.id
  depends_on = [aws_s3_bucket_public_access_block.apostilas_public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.apostilas.arn}/*"
      }
    ]
  })
}

# Configuração CORS para permitir fetch do frontend
resource "aws_s3_bucket_cors_configuration" "apostilas_cors" {
  bucket = aws_s3_bucket.apostilas.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["Content-Length", "Content-Type", "Content-Disposition"]
    max_age_seconds = 3600
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
