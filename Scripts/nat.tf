# EIP para o NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "nat_eip_gratitude"
  }
}

# NAT Gateway na subnet pública
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subrede_publica1_gratitude.id
  tags = {
    Name = "nat_gratitude"
  }
  depends_on = [aws_internet_gateway.igw_cco_gratitude]
}

# Route table privada usando o NAT
resource "aws_route_table" "rtb_privada" {
  vpc_id = aws_vpc.vpc_cco_gratitude.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "rtb_privada_gratitude"
  }
}

# Associar a subnet privada ao route table
resource "aws_route_table_association" "assoc_privada" {
  subnet_id      = aws_subnet.subrede_privada_gratitude.id
  route_table_id = aws_route_table.rtb_privada.id
}
