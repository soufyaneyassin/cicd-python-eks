resource "aws_iam_role" "eks_sa_role" {
     name = "EKS-SA-role"
     assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Federated = aws_iam_openid_connect_provider.eks_oidc.arn
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                    "${data.aws_eks_cluster.main_cluster.identity.oidc.issuer}:aud" = "sts.amazonaws.com"
                    "${data.aws_eks_cluster.main_cluster.identity.oidc.issuer}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }]
     })
}
