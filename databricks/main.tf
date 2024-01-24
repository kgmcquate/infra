module aws {
  source                = "./aws"
  name = var.name
  region = var.region
}

module workspace {
  source                = "./workspace"
  name = var.name
  region = var.region
  databricks_account_id = var.databricks_account_id
  root_storage_bucket = module.aws.root_storage_bucket
  security_group_id = module.aws.default_security_group_id
  subnet_ids = module.aws.public_subnets
  vpc_id = module.aws.vpc_id
}