
resource "aws_instance" "ec2_publica_gratitude_1" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
  key_name      = "vockey"
  subnet_id     = aws_subnet.subrede_publica_gratitude.id
  vpc_security_group_ids = [aws_security_group.sg_publica_gratitude.id]
  associate_public_ip_address = true
  iam_instance_profile        = "LabInstanceProfile"

  # User data - Instala Docker, NGINX e configura diretórios
  user_data = file("${path.module}/user-data-frontend.sh")
  user_data_replace_on_change = true

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
  iam_instance_profile        = "LabInstanceProfile"

  tags = {
    Name = "banco_ec2_privada_gratitude"
  }

  depends_on = [ 
    aws_s3_bucket.imagens
   ]
}

resource "aws_instance" "ec2_privada_gratitude_backend" {
  ami                         = "ami-080e1f13689e07408"
  instance_type               = "t2.medium"
  key_name                    = "vockey"
  subnet_id                   = aws_subnet.subrede_privada_gratitude.id
  vpc_security_group_ids      = [aws_security_group.sg_privada_backend_gratitude.id]
  associate_public_ip_address = false
  iam_instance_profile        = "LabInstanceProfile"

  # User data - Prepara ambiente (MySQL, Java, diretórios)
  user_data = templatefile("${path.module}/user-data-backend.sh", {
    mysql_root_password = var.mysql_root_password
    database_user       = var.database_user
    database_password   = var.database_password
    imagens_bucket       = aws_s3_bucket.imagens.id
    # Variáveis para backup automático
    backup_bucket_name  = aws_s3_bucket.backup_mysql.id
    sns_topic_arn       = aws_sns_topic.backup_notifications.arn
    aws_region          = data.aws_region.current.name
  })
  user_data_replace_on_change = true

  tags = {
    Name = "backend_ec2_privada_gratitude"
  }

  depends_on = [
    aws_instance.ec2_publica_gratitude_1,
    aws_nat_gateway.nat,
    aws_s3_bucket.imagens,
    aws_s3_bucket.backup_mysql,
    aws_sns_topic.backup_notifications
  ]
}