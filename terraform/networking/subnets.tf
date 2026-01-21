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