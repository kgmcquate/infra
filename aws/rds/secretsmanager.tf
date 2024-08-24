resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  db_username = "postgres"
  db_password = random_password.db_password.result
}
 
resource "aws_secretsmanager_secret" "db_creds" {
   name = "main-rds-db-creds"
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id = aws_secretsmanager_secret.db_creds.id
  secret_string = <<EOF
   {
    "username": "${local.db_username}",
    "password": "${local.db_password}",
    "host": "${aws_db_instance.default.endpoint}"
   }
EOF
}