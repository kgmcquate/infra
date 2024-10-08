resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name = "default_ssh_key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_secretsmanager_secret" "main_ssh_private_key" {
  name = "default_ssh_private_key"
}

resource "aws_secretsmanager_secret_version" "private_key_version" {
  secret_id = aws_secretsmanager_secret.main_ssh_private_key.id
  secret_string = tls_private_key.ssh.private_key_pem
}