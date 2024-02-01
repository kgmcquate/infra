variable subnet_id {}
variable security_group_ids {}
variable availability_zone {}
variable ssh_keypair {}
variable domain {}


module "airflow" {
    source =  "../docker_compose_on_ec2"
    name = "airflow"
    key_name = var.ssh_keypair
    instance_type = "t4g.small"
    before_docker_compose_script = "docker-compose up airflow-init"
    docker_compose_str = file("${path.module}/docker-compose.yml")
    subnet_id = var.subnet_id
    availability_zone = var.availability_zone
    vpc_security_group_ids = var.security_group_ids
    associate_public_ip_address = true
    persistent_volume_size_gb = 1
}

data "aws_route53_zone" "primary" {
  name = var.domain
}

locals {
    airflow_domain = "airflow.${var.domain}"
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = local.airflow_domain
  type    = "A"
  ttl     = 300
  records = [module.airflow.public_ip]
}