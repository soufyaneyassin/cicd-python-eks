resource "aws_nat_gateway" "natgw" {
         count = length(aws_subnet.public_subnet)
         allocation_id = aws_eip.eip_natgw[count.index].id
         subnet_id = aws_subnet.public_subnet[count.index].id
         tags = local.tags
         depends_on = [aws_internet_gateway.igw]
}