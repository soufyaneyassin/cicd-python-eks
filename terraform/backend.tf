terraform {
   backend "s3" {
     bucket = "flask-app-state-bucket"
     key = "terraform/state/default.tfstate"
     region = var.region
     dynamodb_table = "terraform-locks"
     encrypt = true
   }
}
