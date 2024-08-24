output db_creds_secret_name {
  value = aws_secretsmanager_secret.db_creds.name
}