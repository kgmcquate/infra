variable subnet_id {}
variable security_group_ids {}
variable availability_zone {}
variable ssh_keypair {}
variable domain {}
variable airflow_s3_bucket {}
variable airflow_s3_prefix {
    default = "airflow/"
}

module "airflow" {
    source =  "../docker_compose_on_ec2"
    name = "airflow"
    key_name = var.ssh_keypair
    instance_type = "t4g.small"
    before_docker_compose_script = <<-EOF
mkdir -p /opt/airflow/
{ crontab -l; echo "30 23 * * * aws s3 sync /opt/airflow/ s3://${var.airflow_s3_bucket}/${var.airflow_s3_prefix}"; } | crontab

export _AIRFLOW_WWW_USER_PASSWORD='${random_password.password.result}'
docker-compose up airflow-init
EOF
    docker_compose_str = file("${path.module}/docker-compose.yml")
    subnet_id = var.subnet_id
    availability_zone = var.availability_zone
    vpc_security_group_ids = var.security_group_ids
    associate_public_ip_address = true
    persistent_volume_size_gb = 1
}


