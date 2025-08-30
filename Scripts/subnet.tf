resource "aws_subnet" "subrede_publica_gratitude"{
vpc_id =  aws_vpc.vpc_cco_gratitude.id
cidr_block = "10.0.0.0/25"
availability_zone = "us-east-1a"
map_public_ip_on_launch = true
tags = {
  Name = "subrede_publica_gratitude"
}
}
resource "aws_subnet" "subrede_privada_gratitude" {
  vpc_id =  aws_vpc.vpc_cco_gratitude.id
  cidr_block = "10.0.1.128/25"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subrede_privada_gratitude"
  }
}