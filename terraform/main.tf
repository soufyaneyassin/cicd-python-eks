


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
       cidr_block = "to_do"
       map_public_ip_on_launch = true
       tags = local.tags

}

resource "aws_subnet" "private_subnet" {
       count = length(data.aws_availability_zones.available.names)
       vpc_id = aws_vpc.main.id
       availability_zone = data.aws_availability_zones.available.names[count.index]
       cidr_block = "to_do"
       tags = local.tags

}


resource "aws_internet_gateway" "igw" {
           vpc_id = aws_vpc.main.id
           tags = local.tags
}

resource "aws_nat_gateway" "natgw" {
         count = aws_subnet.private_subnet.count
         connectivity_type = "private"
         subnet_id = aws_subnet.private_subnet.*.id[count.index]
}

resource "aws_route_table" "public_table" {
       vpc_id = aws_vpc.main.id

       route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
       }
}

resource "aws_route_table" "private_table" {
       count = aws_nat_gateway.natgw.count
       vpc_id = aws_vpc.main.id

       route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.natgw.id[count.index]
       }
}

resource "aws_route_table_association" "public_association" {
        count = aws_subnet.public_subnet.count
        subnet_id = aws_subnet.public_subnet.id[count.index]
        route_table_id = aws_route_table.public_table.id
}

resource "aws_route_table_association" "private_association" {
          count = aws_nat_gateway.natgw.count
          subnet_id = aws_subnet.private_subnet.id[count.index]
          route_table_id = aws_route_table.private_table.id[count.index]
}