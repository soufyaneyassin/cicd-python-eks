data "aws_eks_cluster" "main_cluster" {
    name = "main_eks_cluster"
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
    name = "main_eks_cluster" # we should specify the name of the cluster
}

provider "kubernetes" {
    host = data.aws_eks_cluster.main_cluster.endpoint
    cluser_ca_certificate = base64decode(data.aws_eks_cluster.main_cluster.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.eks_cluster_auth.token
}

provider "aws" {
    region = var.region
}

provider "tls" {}

provider "helm" {
    kubernetes {
        host = data.aws_eks_cluster.main_cluster.endpoint
        cluser_ca_certificate = base64decode(data.aws_eks_cluster.main_cluster.certificate_authority[0].data)
        token = data.aws_eks_cluster_auth.eks_cluster_auth.token
    }
}