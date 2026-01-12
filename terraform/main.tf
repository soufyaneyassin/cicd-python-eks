


# we start by the main vpc for our resources
resource "aws_vpc" "main"{
     cidr_block = local.selected_vpc_cidr
     # we should validate the workspace before proceeding to the creation of any resource
     lifecycle {
        precondition {
            condition = local.is_valid_env
            error_message = "the selected workspace is invalid, please use a valid one"
        }
     }

     tags = local.tags

}

# availability zones are meant for the subnets
data "aws_availability_zones" "available" {
    state = "available"
}

#in this project we're going to use public/private subnets
resource "aws_subnet" "public_subnet" {
       count = length(data.aws_availability_zones.available.names)
       vpc_id = aws_vpc.main.id
       availability_zone = data.aws_availability_zones.available.names[count.index]
       cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
       map_public_ip_on_launch = true
       tags = local.tags

}

resource "aws_subnet" "private_subnet" {
       count = length(data.aws_availability_zones.available.names)
       vpc_id = aws_vpc.main.id
       availability_zone = data.aws_availability_zones.available.names[count.index]
       cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + length(data.aws_availability_zones.available.names))
       tags = local.tags

}


resource "aws_internet_gateway" "igw" {
           vpc_id = aws_vpc.main.id
           tags = local.tags
}

resource "aws_eip" "eip_natgw" {
  count = length(aws_subnet.public_subnet)
  domain                    = "vpc"
}

resource "aws_nat_gateway" "natgw" {
         count = length(aws_subnet.public_subnet)
         allocation_id = aws_eip.eip_natgw[count.index].id
         subnet_id = aws_subnet.public_subnet[count.index].id
         tags = local.tags
         depends_on = [aws_internet_gateway.igw]
}



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