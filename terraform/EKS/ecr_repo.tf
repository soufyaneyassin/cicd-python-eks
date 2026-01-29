resource "aws_ecr_repository" "app_repo" {
        name = "cicd-python-eks-${terraform.workspace}"
        image_tag_mutability = "MUTABLE"
        force_delete = true
        tags = {
            local.tags
        }

}