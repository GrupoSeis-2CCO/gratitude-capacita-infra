
resource "aws_instance" "ec2_publica_gratitude_1" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
  key_name      = "vockey"
  subnet_id     = aws_subnet.subrede_publica1_gratitude.id
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
    mysql_root_password = var.mysql_root_password
  })
  user_data_replace_on_change = true

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