

resource "null_resource" "workspace_guard" {
 count = local.is_valid_env ? 0 : 1

  provisioner "local-exec" {
    command = "echo 'Invalid workspace. Use dev or prod only.' && exit 1"
  }
}





