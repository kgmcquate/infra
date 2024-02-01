variable subnet_id {}
variable security_group_ids {}
variable availability_zone {}
variable ssh_keypair {}
variable domain {}
variable airflow_s3_bucket {}
variable airflow_s3_prefix {
    default = "airflow/"
}

locals {
    startup_script = <<-EOF
#!/bin/bash
set -Eeuxo pipefail

mkdir -p /opt/airflow/

systemd-run --on-boot=1 --on-unit-active=300 aws s3 sync s3://${var.airflow_s3_bucket}/${var.airflow_s3_prefix} /opt/airflow/

export AIRFLOW_PROJ_DIR=/opt/airflow/
export _AIRFLOW_WWW_USER_PASSWORD='${random_password.password.result}'
docker-compose up airflow-init

EOF
}

module "airflow" {
    source =  "../docker_compose_on_ec2"
    name = "airflow"
    key_name = var.ssh_keypair
    instance_type = "t4g.small"
    before_docker_compose_script = local.startup_script
    docker_compose_str = file("${path.module}/docker-compose.yml")
    subnet_id = var.subnet_id
    availability_zone = var.availability_zone
    vpc_security_group_ids = var.security_group_ids
    associate_public_ip_address = true
    persistent_volume_size_gb = 1
}


