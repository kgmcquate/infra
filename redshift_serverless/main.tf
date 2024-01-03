resource "aws_redshiftserverless_namespace" "dbt_testgen" {
  namespace_name = "dbt_testgen"
  admin_username = "dbt_testgen"
  admin_user_password = var.admin_user_password
  db_name = "dbt_testgen"
}

resource "aws_redshiftserverless_workgroup" "dbt_testgen" {
  namespace_name = aws_redshiftserverless_namespace.dbt_testgen.name
  workgroup_name = "dbt_testgen"
  base_capacity = 8
  publicly_accessible = true
  security_group_ids = var.security_group_ids
  subnet_ids = var.subnet_ids
}

