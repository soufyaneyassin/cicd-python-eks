# we start by the main vpc for our resources
resource "aws_vpc" "main"{
     cidr_block = local.selected_vpc_cidr
     # we should validate the workspace before proceeding to the creation of any resource
     lifecycle {
        precondition {
            condition = local.is_valid_env
            error_message = "the selected workspace is invalid, please use a valid one"
        }
     }

     tags = local.tags

}