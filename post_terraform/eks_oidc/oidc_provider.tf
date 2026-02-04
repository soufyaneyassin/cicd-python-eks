resource "aws_iam_openid_connect_provider" "eks_oidc" {
       url = data.aws_eks_cluster.main_cluster.identity.oidc.issuer
       client_id_list = ["sts.amazonaws.com"]
}