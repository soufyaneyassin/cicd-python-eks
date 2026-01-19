


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

# define the eks iam role
resource "aws_iam_role" "eks_cluster_role" {
       name = "eks-cluster-role-${terraform.workspace}"
       assume_role_policy = jsonencode({
              Version = "2012-10-17"
              Statement = [
              {
                     Action = [
                     "sts:AssumeRole",
                     ]
                     Effect = "Allow"
                     Principal = {
                     Service = "eks.amazonaws.com"
                     }
              },
              ]
              })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# define the eks cluster 
resource "aws_eks_cluster" "main_eks_cluster" {
       name = "main-eks-cluster-${terraform.workspace}"
       role_arn = aws_iam_role.eks_cluster_role.arn
      
       vpc_config {
              subnet_ids = concat(
                     aws_subnet.public_subnet[*].id,
                     aws_subnet.private_subnet[*].id
              )
       }
       depends_on = [
              aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
       ]
}

# define the iam role for the worker nodes managed groupe 
resource "aws_iam_role" "eks_node_group_role" {
       name = "eks-node_group-role-${terraform.workspace}"
       assume_role_policy = jsonencode({
                     Statement = [{
                     Action = "sts:AssumeRole"
                     Effect = "Allow"
                     Principal = {
                            Service = "ec2.amazonaws.com"
                     }
                     }]
                     Version = "2012-10-17"
                     })
}

resource "aws_iam_role_policy_attachment" "node-group-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node-group-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node-group-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

# define the eks node group
resource "aws_eks_node_group" "eks-node-group" {
          cluster_name = aws_eks_cluster.main_eks_cluster.name
          node_group_name = "eks-node-group-${terraform.workspace}"
          node_role_arn = aws_iam_role.eks_node_group_role.arn
          subnet_ids = aws_subnet.private_subnet[*].id
          scaling_config {
              desired_size = 2
              max_size = 3
              min_size = 2
          }
          depends_on = [
              aws_iam_role_policy_attachment.node-group-AmazonEKSWorkerNodePolicy,
              aws_iam_role_policy_attachment.node-group-AmazonEKS_CNI_Policy,
              aws_iam_role_policy_attachment.node-group-AmazonEC2ContainerRegistryReadOnly,
              ]
}

# define the eks node group
resource "aws_security_group" "eks_cluster_sg" {
       
}