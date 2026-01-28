data "aws_iam_role" "eks_node_group_role" {
    name = "eks_node_group_role"
}



resource "kubernetes_config_map_v1_data" "aws_auth" {
    metadata {
        name ="aws-auth"
        namespace = "kube-system"
    }
    data = {
        mapRoles = yamlencode([
            {
                rolearn = data.aws_iam_role.eks_node_group_role.arn
                username = "system:node:{{EC2PrivateDNSName}}"
                groups = [
                    "system:bootstrappers",
                    "system:nodes"
                ]
            }
            {
                rolearn = aws_iam_role.github_actions_role.arn
                username = "cicd-github-deployer"
                groups = ["cicd_deployers"]
            }
        ])
    }
}