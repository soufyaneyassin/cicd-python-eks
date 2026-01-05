provider "aws"{
    region = "eu-west-2"
}


resource "aws_s3_bucket" "terraform_state_bucket" {
         bucket = "flask-app-state-bucket"
         acl = "private"

         versioning {
            enabled = true
         }

         tags = {
            Name = "terraform-state-bucket"
         }

         lifecycle {
            prevent_destroy = true
         }
}

resource "aws_dynamodb_table" "terraform-locks" {
    name = "terraform locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
}