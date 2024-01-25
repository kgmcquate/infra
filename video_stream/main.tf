variable subnet_id {}
variable security_group_ids {}
variable availability_zone {}
variable ssh_keypair {}


module "video_stream_pulsar" {
    source =  "../docker_compose_on_ec2"
    name = "video_stream_pulsar"
    key_name = var.ssh_keypair
    instance_type = "t4g.small"
    docker_compose_str = file("${path.module}/docker-compose.yml")
    subnet_id = var.subnet_id
    availability_zone = var.availability_zone
    vpc_security_group_ids = var.security_group_ids
    associate_public_ip_address = true
    persistent_volume_size_gb = 1
}


locals {
    domain = "kevin-mcquate.net"
}

data "aws_route53_zone" "primary" {
  name = local.domain
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "pulsar.${aws_route53_zone.primary.name}"
  type    = "A"
  ttl     = 300
  records = [module.video_stream_pulsar.public_ip]
}
