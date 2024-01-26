variable subnet_id {}
variable security_group_ids {}
variable availability_zone {}
variable ssh_keypair {}
variable jwt_secret_key_base64 {}
variable jwt_token {}


module "video_stream_pulsar" {
    source =  "../docker_compose_on_ec2"
    name = "video_stream_pulsar"
    key_name = var.ssh_keypair
    instance_type = "t4g.small"
    iam_instance_profile = aws_iam_instance_profile.pulsar_profile.name
    docker_compose_str = file("${path.module}/docker-compose.yml")
    before_docker_compose_script = "mkdir -p /root/key/ && echo \"${var.jwt_secret_key_base64}\" | base64 -d > /root/key/secret.key "
    # after_docker_compose_script = <<EOF
    # TOKEN=$(cat /root/superuser_token)
    # aws secretsmanager put-secret-value --secret-id ${aws_secretsmanager_secret.pulsar_admin_token.id} --secret-string "$TOKEN"
    # EOF
    subnet_id = var.subnet_id
    availability_zone = var.availability_zone
    vpc_security_group_ids = var.security_group_ids
    associate_public_ip_address = true
    persistent_volume_size_gb = 1
}

locals {
    domain = "kevin-mcquate.net"
    pulsar_superuser_secret_name = "video_stream_pulsar_superuser_token"
}

resource "aws_secretsmanager_secret" "pulsar_admin_token" {
  name = local.pulsar_superuser_secret_name
}

resource "aws_secretsmanager_secret_version" "pulsar_admin_token" {
  secret_id     = aws_secretsmanager_secret.pulsar_admin_token.id
  secret_string = var.jwt_token
}

data "aws_route53_zone" "primary" {
  name = local.domain
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "pulsar.${data.aws_route53_zone.primary.name}"
  type    = "A"
  ttl     = 300
  records = [module.video_stream_pulsar.public_ip]
}


resource "aws_iam_instance_profile" "pulsar_profile" {
  name = "pulsar_profile"
  role = aws_iam_role.pulsar_profile.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "pulsar_profile" {
  name               = "pulsar_profile"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  
  inline_policy {
    name = "pulsar_superuser_token_access"

    policy = jsonencode({
      Version = "2012-10-17"
      
    #   secretsmanager:Name
      Statement = [
        {
          Action   = [
                "secretsmanager:CreateSecret", 
                "secretsmanager:DescribeSecret",
                "secretsmanager:GetSecretValue",
                "secretsmanager:PutSecretValue"
            ]
          Effect   = "Allow"
          Resource = "*"
          Condition = {
            "StringEquals" = {
                "secretsmanager:Name" = local.pulsar_superuser_secret_name
            }
          }
        }
      ]
    })
  }
}