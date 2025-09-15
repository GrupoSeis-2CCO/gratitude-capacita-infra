# Subnet pública 1 - zona us-east-1a
resource "aws_subnet" "subrede_publica1_gratitude" {
  vpc_id                  = aws_vpc.vpc_cco_gratitude.id
  cidr_block              = var.cidr_publica_1
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subrede_publica1_gratitude"
  }
}

# Subnet pública 2 - zona us-east-1b
resource "aws_subnet" "subrede_publica2_gratitude" {
  vpc_id                  = aws_vpc.vpc_cco_gratitude.id
  cidr_block              = var.cidr_publica_2
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subrede_publica2_gratitude"
  }
}

# Subnet privada - zona us-east-1a
resource "aws_subnet" "subrede_privada_gratitude" {
  vpc_id                  = aws_vpc.vpc_cco_gratitude.id
  cidr_block              = var.cidr_privada
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "subrede_privada_gratitude"
  }
}
