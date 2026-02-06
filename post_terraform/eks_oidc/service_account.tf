resource "kubernetes_service_account" "alb_controller" {
    metadata {
        name = "alb_controller_svacc"
        namespace = "kube-system"
        annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.eks_sa_role.arn
        }
    }

}