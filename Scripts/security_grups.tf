resource "aws_security_group" "sg_publica_gratitude" {
  name = "sg_publica_gratitude"
  description = "Permite SSH de qualquer IP"
  vpc_id = aws_vpc.vpc_cco_gratitude.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_qualquer_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_qualquer_ip]
  }
}

resource "aws_security_group" "sg_privada_gratitude" {
  name = "sg_privada_gratitude"
  description = "Permite SSH de qualquer IP"
  vpc_id = aws_vpc.vpc_cco_gratitude.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc_cco_gratitude.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_qualquer_ip]
  }
}
