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


    create_tenants_script = <<-EOF
    bin/pulsar-admin tenants create video_stream
    EOF

    create_namespaces_script =  <<-EOF
    bin/pulsar-admin namespaces create video_stream/video_stream
    bin/pulsar-admin namespaces grant-permission video_stream/video_stream --role superuser --actions produce,consume
    EOF

    create_topics_script = <<-EOF
    bin/pulsar-admin topics create-partitioned-topic video_stream/video_stream/raw-livestream-frames -p 4
    bin/pulsar-admin topics create-partitioned-topic video_stream/video_stream/processed-livestream-frames -p 4
    EOF
}

# 

data "template_file" "docker-compose" {
  template = "${file("${path.module}/docker-compose.template.yml")}"
  vars = {
    broker_domain = local.pulsar_domain
    broker_api_port = "${local.broker_api_port}"
    broker_pulsar_port =  "${local.broker_pulsar_port}"
    cluster_name = local.cluster_name
    superuser_name = local.superuser_name
    auth_token = var.jwt_token
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
    after_docker_compose_script = <<-EOF
    ${local.create_tenants_script} 
    ${local.create_namespaces_script}
    ${local.create_topics_script}
    EOF
    subnet_id = var.subnet_ids[2]
    availability_zone = var.availability_zones[2]
    vpc_security_group_ids = var.security_group_ids
    associate_public_ip_address = true
    persistent_volume_size_gb = 1

}
