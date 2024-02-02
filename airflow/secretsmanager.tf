resource "random_password" "airflow_admin_password" {
  length           = 32
  special          = false
}

resource "aws_secretsmanager_secret" "airflow_admin_password" {
   name = "airflow_admin_password"
}

# Store private key in secretsmanager for later access
resource "aws_secretsmanager_secret_version" "private_key_version" {
  secret_id = aws_secretsmanager_secret.airflow_admin_password.id
  secret_string = random_password.airflow_admin_password.result
}
