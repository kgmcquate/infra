data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "lake-freeze" {
    source = "./lake-freeze"
    POSTGRES_PWD = var.POSTGRES_PWD
    vpc_id = module.vpc.vpc_id
    public_subnet_ids = module.vpc.public_subnets
    private_subnet_ids = module.vpc.private_subnets

    depends_on = [ module.vpc ]
}

module "snowflake" {
    source = "./snowflake"
    provider_account = "ircmtcn-ekb34223"
    provider_username = "CICD_INFRA"
    provider_password = var.snowflake_password
    dbt_testgen_password = var.dbt_testgen_snowflake_password
}

module "redshift_serverless" {
  source = "./redshift_serverless"
  admin_user_password = var.dbt_testgen_redshift_password
  security_group_ids = [aws_security_group.allow_all.id]
  subnet_ids = module.vpc.public_subnets
}


module "databricks" {
  source = "./databricks"

  providers = {
    databricks = databricks.mws
    databricks.main-ws = databricks.main-ws
  }

  name = "main"
  databricks_account_id = var.databricks_account_id
  region = "us-east-1"
}

module video_stream {
  source = "./video_stream"

  subnet_id = module.vpc.public_subnets[2]
  availability_zone = module.vpc.azs[2]
  security_group_ids = [aws_security_group.allow_all.id]
  ssh_keypair = aws_key_pair.ssh.key_name
  jwt_secret_key_base64 = var.pulsar_jwt_secret_key_base64
  jwt_token = var.pulsar_jwt_token
}

# module airflow {
#   source = "./airflow"

#   subnet_id = module.vpc.public_subnets[2]
#   availability_zone = module.vpc.azs[2]
#   security_group_ids = [aws_security_group.allow_all.id]
#   ssh_keypair = aws_key_pair.ssh.key_name
# }