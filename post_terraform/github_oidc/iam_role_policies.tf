resource "aws_iam_role" "github_actions_role" {
     name = "github-actions-role"
     assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Federated = aws_iam_openid_connect_provider.github.arn
            }
            Action = "sts:AssumeRoleWithWebIdentity"
            Condition = {
                StringEquals = {
                    "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
                }
                StringLike = {
                    "token.actions.githubusercontent.com:sub" = "repo:soufyaneyassin/cicd-python-eks:*"
                }
            }
        }]
     })
}

resource "aws_iam_policy" "eks_access" {
       name = "github-eks-access"
       policy = jsonencode({
            Version = "2012-10-17"
            Statement = [{
                Effect = "Allow"
                Action = ["eks:DescribeCluster"]
                Resource = data.aws_eks_cluster.main_cluster.arn
            }]
       })
}

resource "aws_iam_role_policy_attachment" "eks_access_attach" {
    role = aws_iam_role.github_actions_role.name
    policy_arn = aws_iam_policy.eks_access.arn
}