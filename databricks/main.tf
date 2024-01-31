module aws {
  source                = "./aws"

  name = var.name
  region = var.region
  databricks_account_id = var.databricks_account_id
}

module main_workspace {
  source                = "./workspace"
  name = var.name
  region = var.region
  databricks_account_id = var.databricks_account_id
  cross_account_role_arn = module.aws.cross_account_role_arn
  root_storage_bucket = module.aws.root_storage_bucket
  security_group_id = module.aws.default_security_group_id
  subnet_ids = module.aws.private_subnets
  vpc_id = module.aws.vpc_id
}


module main_workspace_objects {
  source                = "./main_workspace_objects"

  # admin_user = data.databricks_user.me

  providers = {
    databricks.main-ws = databricks.main-ws
  }
  depends_on = [module.main_workspace]
}