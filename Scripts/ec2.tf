
resource "aws_instance" "ec2_publica_gratitude_1" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  key_name      = "vockey"
  subnet_id     = aws_subnet.subrede_publica_gratitude.id
  vpc_security_group_ids = [aws_security_group.sg_publica_gratitude.id]
  associate_public_ip_address = true

  tags = {
    Name = "01_ec2_publica_gratitude"
  }
}

resource "aws_instance" "ec2_publica_gratitude_2" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  key_name      = "vockey"
  subnet_id     = aws_subnet.subrede_publica_gratitude.id
  vpc_security_group_ids = [aws_security_group.sg_publica_gratitude.id]
  associate_public_ip_address = true

  tags = {
    Name = "02_ec2_publica_gratitude"
  }
}

resource "aws_instance" "ec2_privada_gratitude" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  key_name = "vockey"
  subnet_id     = aws_subnet.subrede_privada_gratitude.id
  vpc_security_group_ids = [aws_security_group.sg_privada_gratitude.id]
  associate_public_ip_address = false

  tags = {
    Name = "db_ec2_privada_gratitude"
  }
}

resource "aws_instance" "ec2_privada_gratitude" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  key_name = "vockey"
  subnet_id     = aws_subnet.subrede_privada_gratitude.id
  vpc_security_group_ids = [aws_security_group.sg_privada_gratitude.id]
  associate_public_ip_address = false

  tags = {
    Name = "be_ec2_privada_gratitude"
  }
}