module aws {
  source                = "./aws"

  name = var.name
  region = var.region
  databricks_account_id = var.databricks_account_id
}

module workspace {
  source                = "./workspace"
  name = var.name
  region = var.region
  databricks_account_id = var.databricks_account_id
  cross_account_role_arn = module.aws.cross_account_role_arn
  root_storage_bucket = module.aws.root_storage_bucket
  security_group_id = module.aws.default_security_group_id
  subnet_ids = module.aws.public_subnets
  vpc_id = module.aws.vpc_id
}

data "databricks_user" "me" {
  provider = databricks
  user_name = "kgmcquate@gmail.com"
}

module main_workspace {
  source                = "./main_workspace"

  providers = {
    databricks.main-ws = databricks.main-ws
  }
}