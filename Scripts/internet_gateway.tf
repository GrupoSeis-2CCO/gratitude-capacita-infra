resource "aws_internet_gateway" "igw_cco_gratitude" {
  vpc_id = aws_vpc.vpc_cco_gratitude.id
  tags = {
    Name = "cco-igw_gratitude"
  }
}