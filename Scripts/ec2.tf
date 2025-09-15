
resource "aws_instance" "ec2_publica_gratitude_1" {
  ami           = "ami-00ca32bbc84273381"
  instance_type = "t2.micro"
  key_name      = "vockey"
  subnet_id     = aws_subnet.subrede_publica1_gratitude.id
  vpc_security_group_ids = [aws_security_group.sg_publica_gratitude.id]
  associate_public_ip_address = true

  tags = {
    Name = "01_ec2_publica_gratitude"
  }
}

resource "aws_instance" "ec2_publica_gratitude_2" {
  ami           = "ami-00ca32bbc84273381"
  instance_type = "t2.micro"
  key_name      = "vockey"
  subnet_id     = aws_subnet.subrede_publica2_gratitude.id
  vpc_security_group_ids = [aws_security_group.sg_publica_gratitude.id]
  associate_public_ip_address = true

  tags = {
    Name = "02_ec2_publica_gratitude"
  }
}

resource "aws_instance" "ec2_privada_gratitude_1" {
  ami           = "ami-00ca32bbc84273381"
  instance_type = "t2.micro"
  key_name      = "vockey"
  subnet_id     = aws_subnet.subrede_privada_gratitude.id
  vpc_security_group_ids = [aws_security_group.sg_privada1_gratitude.id]
  associate_public_ip_address = false

  tags = {
    Name = "db_ec2_privada_gratitude"
  }
}

resource "aws_instance" "ec2_privada_gratitude_2" {
  ami           = "ami-00ca32bbc84273381"
  instance_type = "t2.micro"
  key_name      = "vockey"
  subnet_id     = aws_subnet.subrede_privada_gratitude.id
  vpc_security_group_ids = [aws_security_group.sg_privada2_gratitude.id]
  associate_public_ip_address = false

  tags = {
    Name = "be_ec2_privada_gratitude"
  }
}