resource "kubernetes_cluster_role" "ci_cd_deployer" {
    metadata {
        name = "ci_cd_deployer"
    }
  rule {
    api_groups = ["apps", ""]
    resources  = ["deployments", "services", "configmaps", "secrets", "pods", "namespaces"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  
  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "ci_cd_binding" {
    metadata {
        name = "ci_cd_binding"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = kubernetes_cluster_role.ci_cd_deployer.metadata[0].name
    }
    subject {
        api_group = "rbac.authorization.k8s.io"
        kind = "Group"
        name = "cicd_deployers"
    }
}