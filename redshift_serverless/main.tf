resource "aws_redshiftserverless_namespace" "dbt_testgen" {
  namespace_name = "dbt-testgen"
  admin_username = "dbt_testgen"
  admin_user_password = var.admin_user_password
  db_name = "dbt_testgen"
}

resource "aws_redshiftserverless_workgroup" "dbt_testgen" {
  namespace_name = aws_redshiftserverless_namespace.dbt_testgen.id
  workgroup_name = "dbt-testgen"
  base_capacity = 8
  publicly_accessible = true
  security_group_ids = var.security_group_ids
  subnet_ids = var.subnet_ids
}

resource "aws_secretsmanager_secret" "db_creds" {
   name = "redshift-db-creds"
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id = aws_secretsmanager_secret.db_creds.id
  secret_string = <<EOF
   {
    "password": "${var.admin_user_password}"
   }
EOF
}