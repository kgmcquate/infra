resource "aws_secretsmanager_secret" "pulsar_admin_token" {
  name = local.pulsar_superuser_secret_name
}

resource "aws_secretsmanager_secret_version" "pulsar_admin_token" {
  secret_id     = aws_secretsmanager_secret.pulsar_admin_token.id
  secret_string = var.jwt_token
}

