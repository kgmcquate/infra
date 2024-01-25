

module "video_stream_pulsar" {
    source =  "../docker_compose_on_ec2"
    name = "video_stream_pulsar"
    key_name = aws_key_pair.ssh.key_name
    instance_type = "t4g.nano"
    docker_compose_str = file("${path.module}/docker-compose.yml")
    subnet_id = module.vpc.public_subnets[2]
    availability_zone = module.vpc.azs[2]
    vpc_security_group_ids = [aws_security_group.allow_all.id]
    associate_public_ip_address = true
    persistent_volume_size_gb = 1
}