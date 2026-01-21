resource "aws_eip" "eip_natgw" {
  count = length(aws_subnet.public_subnet)
  domain                    = "vpc"
}