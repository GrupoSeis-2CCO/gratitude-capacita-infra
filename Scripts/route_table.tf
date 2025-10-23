resource "aws_route_table" "route_table_publica_gratitude" {
  vpc_id = aws_vpc.vpc_cco_gratitude.id

  route {
    cidr_block = var.cidr_qualquer_ip
    gateway_id = aws_internet_gateway.igw_cco_gratitude.id
  }

  tags = {
    Name = "subrede-publica-route-table_gratitude"
  }
}

resource "aws_route_table_association" "subrede_publica1_gratitude" {
  subnet_id      = aws_subnet.subrede_publica_gratitude.id
  route_table_id = aws_route_table.route_table_publica_gratitude.id
}

# resource "aws_route_table_association" "subrede_publica2_gratitude" {
#   subnet_id      = aws_subnet.subrede_publica2_gratitude.id
#   route_table_id = aws_route_table.route_table_publica_gratitude.id
# }