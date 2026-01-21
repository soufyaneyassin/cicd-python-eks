# define the eks cluster security group
resource "aws_security_group" "eks_cluster_sg" {
       name = "eks_cluster_sg_${terraform.workspace}"
       description = "allow tls traffic from node group"
       vpc_id = aws_vpc.main.id
       tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "eks_cluster_tls_ipv4" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  referenced_security_group_id = aws_security_group.eks_node_group_sg.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "eks_cluster_all_tls_traffic" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# define the eks node groug security group
resource "aws_security_group" "eks_node_group_sg"{
       name = "eks_node_group_sg_${terraform.workspace}"
       description = "define trrafic rules  for eks node group"
       vpc_id = aws_vpc.main.id
       tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "ng_node_to_node" {
  security_group_id = aws_security_group.eks_node_group_sg.id
  referenced_security_group_id = aws_security_group.eks_node_group_sg.id
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
}

resource "aws_vpc_security_group_ingress_rule" "ng_eks_to_node" {
  security_group_id = aws_security_group.eks_node_group_sg.id
  referenced_security_group_id = aws_security_group.eks_cluster_sg.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "eks_node_group_all_traffic" {
  security_group_id = aws_security_group.eks_node_group_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}