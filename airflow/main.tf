variable subnet_id {}
variable security_group_ids {}
variable availability_zone {}
variable ssh_keypair {}


module "airflow" {
    source =  "../docker_compose_on_ec2"
    name = "airflow"
    key_name = var.ssh_keypair
    instance_type = "t4g.medium"
    before_docker_compose_script = "docker-compose -f /var/run/docker-compose.yml up airflow-init"
    docker_compose_str = file("${path.module}/docker-compose.yml")
    subnet_id = var.subnet_id
    availability_zone = var.availability_zone
    vpc_security_group_ids = var.security_group_ids
    associate_public_ip_address = true
    persistent_volume_size_gb = 1
}