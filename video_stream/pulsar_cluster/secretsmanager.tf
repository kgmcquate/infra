resource "aws_secretsmanager_secret" "pulsar_admin_token" {
  name = local.pulsar_superuser_secret_name
}

resource "aws_secretsmanager_secret_version" "pulsar_admin_token" {
  secret_id     = aws_secretsmanager_secret.pulsar_admin_token.id
  secret_string = jsonencode(
    {
      token = var.jwt_token
      user = local.superuser_name
      broker_host = local.pulsar_domain
      api_port = local.broker_api_port
      pulsar_port = local.broker_pulsar_port
    }
  )
}

