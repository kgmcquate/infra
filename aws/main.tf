module "redshift_serverless" {
  source = "./redshift_serverless"
  security_group_ids = [aws_security_group.allow_all.id]
  subnet_ids = module.vpc.public_subnets
}

module "rds" {
  source = "./rds"
  subnet_ids = module.vpc.public_subnets
  security_group_ids = [aws_security_group.allow_all.id]
}

# module "airflow" {
#   source = "./airflow"
#   subnet_id = module.vpc.public_subnets[2]
#   availability_zone = module.vpc.azs[2]
#   security_group_ids = [aws_security_group.allow_all.id]
#   ssh_keypair = aws_key_pair.ssh.key_name
#   airflow_s3_bucket = aws_s3_bucket.deployment_zone.bucket
#   domain = var.main_domain
#   posgtres_db_secret_name = module.rds.db_creds_secret_name
#
#   depends_on = [module.rds]
# }