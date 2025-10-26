
resource "aws_instance" "ec2_publica_gratitude_1" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
  key_name      = "vockey"
  subnet_id     = aws_subnet.subrede_publica_gratitude.id
  vpc_security_group_ids = [aws_security_group.sg_publica_gratitude.id]
  associate_public_ip_address = true

  tags = {
    Name = "01_ec2_publica_gratitude"
  }
}

resource "aws_instance" "ec2_privada_gratitude_bd" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
  key_name      = "vockey"
  subnet_id     = aws_subnet.subrede_privada_gratitude.id
  vpc_security_group_ids = [aws_security_group.sg_privada_bd_gratitude.id]
  associate_public_ip_address = false

  tags = {
    Name = "banco_ec2_privada_gratitude"
  }
}

resource "aws_instance" "ec2_privada_gratitude_backend" {
  ami                         = "ami-080e1f13689e07408"
  instance_type               = "t2.medium"
  key_name                    = "vockey"
  subnet_id                   = aws_subnet.subrede_privada_gratitude.id
  vpc_security_group_ids      = [aws_security_group.sg_privada_backend_gratitude.id]
  associate_public_ip_address = false

  # User data - Passando nomes dos buckets S3 como variaveis
  user_data = templatefile("${path.module}/user-data-backend.sh", {
    bronze_bucket       = aws_s3_bucket.bronze.id
    silver_bucket       = aws_s3_bucket.silver.id
    gold_bucket         = aws_s3_bucket.gold.id
    backup_bucket       = var.backup_bucket_name != "" ? var.backup_bucket_name : aws_s3_bucket.db_backups[0].id
    admin_email         = var.admin_email
    db_name             = var.db_name
    db_user             = var.db_user
    db_password         = var.db_password
    mysql_root_password = var.mysql_root_password
    jwt_secret          = var.jwt_secret
    smtp_host           = var.smtp_host
    smtp_port           = var.smtp_port
    smtp_user           = var.smtp_user
    smtp_pass           = var.smtp_pass
    smtp_from           = var.smtp_from
  })
  user_data_replace_on_change = true

  iam_instance_profile = var.instance_profile_name != "" ? var.instance_profile_name : (length(aws_iam_instance_profile.backup_profile) > 0 ? aws_iam_instance_profile.backup_profile[0].name : null)

  tags = {
    Name = "backend_ec2_privada_gratitude"
  }

  depends_on = [
    aws_instance.ec2_publica_gratitude_1,
    aws_nat_gateway.nat,
    aws_s3_bucket.bronze,
    aws_s3_bucket.silver,
    aws_s3_bucket.gold
  ]
}