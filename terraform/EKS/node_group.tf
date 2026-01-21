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