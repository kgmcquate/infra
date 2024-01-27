variable subnet_ids {}
variable vpc_id {}
variable security_group_ids {}
variable availability_zones {}
variable ssh_keypair {}
variable jwt_secret_key_base64 {}
variable jwt_token {}

locals {
    domain = "kevin-mcquate.net"
    pulsar_superuser_secret_name = "pulsar_video_stream_superuser_token"
    broker_api_port = 8080
    broker_pulsar_port = 6650
    cluster_name = "cluster-a"
    superuser_name = "superuser"
    pulsar_domain = "pulsar.${data.aws_route53_zone.primary.name}"
}

data "template_file" "docker-compose" {
  template = "${file("${path.module}/docker-compose.template.yml")}"
  vars = {
    broker_api_port = "${local.broker_api_port}"
    broker_pulsar_port =  "${local.broker_pulsar_port}"
    cluster_name = local.cluster_name
    superuser_name = local.superuser_name
  }
}

module "video_stream_pulsar" {
    source =  "../../docker_compose_on_ec2"
    name = "video_stream_pulsar"
    key_name = var.ssh_keypair
    instance_type = "t4g.small"
    iam_instance_profile = aws_iam_instance_profile.pulsar_profile.name
    docker_compose_str = data.template_file.docker-compose.rendered
    before_docker_compose_script = "mkdir -p /root/key/ && echo \"${var.jwt_secret_key_base64}\" | base64 -d > /root/key/secret.key "
    subnet_id = var.subnet_ids[2]
    availability_zone = var.availability_zones[2]
    vpc_security_group_ids = var.security_group_ids
    associate_public_ip_address = true
    persistent_volume_size_gb = 1

}
