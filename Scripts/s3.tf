# Buckets S3 para RAW, TRUSTED e CLIENT
resource "aws_s3_bucket" "raw" {
  bucket = "gratitude-raw-${random_string.bucket_aleatorio.result}"
  force_destroy = true
  tags = {
    Name = "gratitude-raw"
  }
}

resource "aws_s3_bucket" "trusted" {
  bucket = "gratitude-trusted-${random_string.bucket_aleatorio.result}"
  force_destroy = true
  tags = {
    Name = "gratitude-trusted"
  }
}

resource "aws_s3_bucket" "client" {
  bucket = "gratitude-client-${random_string.bucket_aleatorio.result}"
  force_destroy = true
  tags = {
    Name = "gratitude-client"
  }
}

# Gerador de sufixo único para buckets S3
resource "random_string" "bucket_aleatorio" {
  length  = 8
  special = false
  upper   = false
}
