
resource "aws_instance" "ec2_publica_gratitude" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  key_name      = "vockey"
  subnet_id     = aws_subnet.subrede_publica_gratitude.id
  vpc_security_group_ids = [aws_security_group.sg_publica_gratitude.id]
  associate_public_ip_address = true

  tags = {
    Name = "ec2_publica_gratitude"
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
    Name = "ec2_privada_gratitude"
  }
}