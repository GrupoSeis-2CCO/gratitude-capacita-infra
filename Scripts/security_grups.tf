resource "aws_security_group" "sg_publica_gratitude" {
  name        = "sg_publica_gratitude"
  description = "Permite acesso HTTP HTTPS e SSH de qualquer IP"
  vpc_id      = aws_vpc.vpc_cco_gratitude.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_qualquer_ip]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_qualquer_ip]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_qualquer_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_qualquer_ip]
  }

  tags = {
    Name = "sg_publica_gratitude"
  }
}

resource "aws_security_group" "sg_privada_backend_gratitude" {
  name        = "sg_privada_backend_gratitude"
  description = "Permite acesso apenas das EC2s publicas"
  vpc_id      = aws_vpc.vpc_cco_gratitude.id

  ingress {
    description     = "Spring Boot API"
    from_port       = 8080
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_publica_gratitude.id]
  }

  ingress {
    description     = "Acesso interno das EC2s publicas"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_publica_gratitude.id]
  }

  ingress {
    description     = "SSH das EC2s publicas"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_publica_gratitude.id]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_qualquer_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_qualquer_ip]
  }

  tags = {
    Name = "sg_privada_backend_gratitude"
  }
}

resource "aws_security_group" "sg_privada_bd_gratitude" {
  name        = "sg_privada_bd_gratitude"
  description = "Permite acesso apenas das EC2s privadas do grupo 1"
  vpc_id      = aws_vpc.vpc_cco_gratitude.id

  ingress {
    description     = "Acesso interno das EC2s privadas grupo 1"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_privada_backend_gratitude.id]
  }

  ingress {
    description     = "SSH das EC2s privadas grupo 1"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_privada_backend_gratitude.id]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_qualquer_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_qualquer_ip]
  }

  tags = {
    Name = "sg_privada_bd_gratitude"
  }
}