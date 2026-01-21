# define the eks cluster 
resource "aws_eks_cluster" "main_eks_cluster" {
       name = "main-eks-cluster-${terraform.workspace}"
       role_arn = aws_iam_role.eks_cluster_role.arn
      
       vpc_config {
              subnet_ids = concat(
                     aws_subnet.public_subnet[*].id,
                     aws_subnet.private_subnet[*].id
              )
              security_group_ids = [aws_security_group.eks_cluster_sg.id]
       }
       depends_on = [
              aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
       ]
}