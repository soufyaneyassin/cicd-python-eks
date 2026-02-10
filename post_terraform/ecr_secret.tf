data "aws_caller_identity" "current" {}

data "aws_ecr_authorization_token" "token" {}

resource "kubernetes_secret" "ecr_auth" {
    metadata {
        name = "ecr-auth-secret"
        namespace = "default"
    }

    type = "kubernetes.io/dockerconfigjson"

    data = {
        ".dockerconfigjson" = jsonencode({
            auths = {
                 "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com" = {
                  auth = base64encode("AWS:${data.aws_ecr_authorization_token.token.password}")
            }
            }
        })
    }
}