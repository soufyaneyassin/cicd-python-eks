locals {
  env = terraform.workspace

  #safety: we use either dev or prod
  allowed_envs = ["dev", "prod"]
  is_valid_env = contains(local.allowed_envs, local.env)
  selected_vpc_cidr = local.env == "prod" ? "10.1.0.0/16" : "10.0.0.0/16"
  

  tags = {
    Environement = local.env
    ManagedBy = "Terraform"
    Project = "flask-app" 
  }
}
