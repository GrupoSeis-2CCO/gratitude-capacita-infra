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


resource "random_string" "bucket_aleatorio" {
  length  = 8
  special = false
  upper   = false
}
