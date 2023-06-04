locals {
  db_username = "postgres"
  db_password = var.POSTGRES_PWD
}
 
resource "aws_secretsmanager_secret" "db_creds" {
   name = "lake-freeze-db-creds"
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id = aws_secretsmanager_secret.db_creds.id
  secret_string = <<EOF
   {
    "username": "${local.db_username}",
    "password": "${local.db_password}"
   }
EOF
}