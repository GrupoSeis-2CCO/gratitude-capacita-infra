
resource "aws_vpc" "vpc_cco_gratitude" {
  cidr_block = "10.0.0.0/21"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "vpc_gratitude"
  }
}