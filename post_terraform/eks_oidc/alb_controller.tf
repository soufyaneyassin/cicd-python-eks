resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  
  set {
    name  = "clusterName"
    value = data.aws_eks_cluster.main_cluster.name
  }
  
  set {
    name  = "serviceAccount.create"
    value = "false"  # We created it above
  }
  
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller.metadata[0].name
  }
  
  depends_on = [
    kubernetes_service_account.alb_controller,
    aws_iam_role.eks_sa_role
  ]
}