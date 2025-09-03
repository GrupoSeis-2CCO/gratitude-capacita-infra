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

resource "random_string" "bucket_aleatorio" {
  length  = 8
  special = false
  upper   = false
}
