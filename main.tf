
module "aws" {
  source = "./aws"
  region = var.AWS_REGION
  account_id = var.aws_account_id
}


module "snowflake" {
    source = "./snowflake"
    provider_account = var.snowflake_account
    provider_username = "CICD_INFRA"
    provider_password = var.snowflake_password
    dbt_testgen_password = var.dbt_testgen_snowflake_password
}

# module "databricks" {
#   source = "./databricks"
#
#   providers = {
#     databricks = databricks.mws
#     databricks.main-ws = databricks.main-ws
#   }
#
#   name = "dataricks-main"
#   databricks_account_id = var.databricks_account_id
#   region = var.AWS_REGION
# }

# module video_stream {
#   source = "./video_stream"

#   subnet_ids = module.vpc.public_subnets
#   availability_zones = module.vpc.azs
#   security_group_ids = [aws_security_group.allow_all.id]
#   vpc_id = module.vpc.vpc_id
#   ssh_keypair = aws_key_pair.ssh.key_name
#   jwt_secret_key_base64 = var.pulsar_jwt_secret_key_base64
#   jwt_token = var.pulsar_jwt_token
# }

module "confluent" {
    source = "./confluent"

    confluent_cloud_api_key = var.confluent_cloud_api_key
    confluent_cloud_api_secret = var.confluent_cloud_api_secret
    aws_region = var.AWS_REGION
}