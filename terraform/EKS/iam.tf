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