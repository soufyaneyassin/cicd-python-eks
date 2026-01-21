resource "aws_route_table" "public_table" {
       vpc_id = aws_vpc.main.id

       route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
       }
       tags = local.tags
}

resource "aws_route_table" "private_table" {
       count = length(aws_nat_gateway.natgw)
       vpc_id = aws_vpc.main.id

       route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.natgw[count.index].id
       }
        tags = local.tags
}

resource "aws_route_table_association" "public_association" {
        count = length(aws_subnet.public_subnet)
        subnet_id = aws_subnet.public_subnet[count.index].id
        route_table_id = aws_route_table.public_table.id
        tags = local.tags
}

resource "aws_route_table_association" "private_association" {
          count = length(aws_nat_gateway.natgw)
          subnet_id = aws_subnet.private_subnet[count.index].id
          route_table_id = aws_route_table.private_table[count.index].id
          tags = local.tags
}