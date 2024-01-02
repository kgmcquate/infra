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
