# s3.tf - Buckets S3 para ETL

# Bucket CLIENT
resource "aws_s3_bucket" "client_data" {
  bucket = "${var.project_name}-client-data-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "${var.project_name}-client-data"
    Type = "CLIENT"
  }
}

# Bucket TRUSTED
resource "aws_s3_bucket" "trusted_data" {
  bucket = "${var.project_name}-trusted-data-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "${var.project_name}-trusted-data"
    Type = "TRUSTED"
  }
}

# Bucket RAW
resource "aws_s3_bucket" "raw_data" {
  bucket = "${var.project_name}-raw-data-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "${var.project_name}-raw-data"
    Type = "RAW"
  }
}

# ID aleatório para nomes únicos
resource "random_id" "bucket_suffix" {
  byte_length = 4
}