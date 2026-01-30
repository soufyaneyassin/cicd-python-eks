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

resource "aws_iam_policy" "ecr_access" {
         name = "github-ecr-access"
         policy = jsonencode(
            {
                "Version":"2012-10-17"		 	 	 
                "Statement": [
                    {
                        "Effect": "Allow"
                        "Action": [
                            "ecr:CompleteLayerUpload",
                            "ecr:UploadLayerPart",
                            "ecr:InitiateLayerUpload",
                            "ecr:BatchCheckLayerAvailability",
                            "ecr:PutImage",
                            "ecr:BatchGetImage",
                            "ecr:GetDownloadUrlForLayer",
                            "ecr:GetRepositoryPolicy",
                            "ecr:DescribeRepositories",
                            "ecr:ListImages",
                            "ecr:DescribeImages",
                        ]
                        Resource = "arn:aws:ecr:${var.region}:111122223333:repository/cicd-python-eks-${terraform.workspace}"
                    },
                    {
                        "Effect": "Allow"
                        "Action": "ecr:GetAuthorizationToken"
                        "Resource": "*"
                    }
                ]
            }
         )
}

resource "aws_iam_role_policy_attachment" "eks_access_attach" {
    role = aws_iam_role.github_actions_role.name
    policy_arn = aws_iam_policy.eks_access.arn
}

resource "aws_iam_role_policy_attachment" "ecr_access_attach" {
    role = aws_iam_role.github_actions_role.name
    policy_arn = aws_iam_policy.ecr_access.arn
}