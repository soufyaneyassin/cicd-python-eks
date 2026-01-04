
# select the terraform workspace (dev, prod)
terraform {
    required_version = ">= 0.12"    
}

resource "aws_s3_bucket" "terraform_state_bucket" {
         bucket = "flask-app-state-bucket-${terraform.workspace}"
         acl = "private"

         versioning {
            enabled = true
         }

         tags = {
            Name = "state-bucket-${terraform.workspace}"
         }

         lifecycle {
            prevent_destroy = false
         }
}

terraform {
   backend "s3" {
     bucket = "flask-app-state-bucket-dev"
     key = "terraform/state/default.tfstate"
     region = "eu-west-2"
   }
}

