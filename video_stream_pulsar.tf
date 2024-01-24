# ===== OUR MAGIC DOCKER-COMPOSE.YML FILE HERE =====
# It is also possible to get Terraform to read an external `docker-compose.yml`
# file and load it into this variable.
# We'll be showing off a demo nginx page.
variable "example_docker_compose" {
    type = string
    default =  <<EOF
version: "3.1"
services:
  hello:
    image: nginxdemos/hello
    restart: always
    ports:
      - 80:80
EOF
}


module "video_stream_pulsar" {
    source =  "./docker_compose_on_ec2"
    name = "video_stream_pulsar"
    key_name = aws_key_pair.ssh.key_name
    instance_type = "t4g.nano"
    docker_compose_str = var.example_docker_compose
    subnet_id = module.vpc.public_subnets[0]
    availability_zone = module.vpc.azs[2]
    vpc_security_group_ids = [module.vpc.default_security_group_id]
    associate_public_ip_address = true
    persistent_volume_size_gb = 1
}