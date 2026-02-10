resource "aws_nat_gateway" "natgw" {
         allocation_id = aws_eip.eip_natgw.id
         subnet_id = aws_subnet.public_subnet[0].id
         tags = local.tags
         depends_on = [aws_internet_gateway.igw]
}