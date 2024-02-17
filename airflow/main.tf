variable subnet_id {}
variable security_group_ids {}
variable availability_zone {}
variable ssh_keypair {}
variable domain {}
variable airflow_s3_bucket {}
variable airflow_dags_s3_prefix {
    default = "airflow/dags/"
}

locals {
    startup_script = <<-EOF

cat > Dockerfile <<-"FILE"
FROM apache/airflow:2.8.1-python3.11
RUN pip install astronomer-cosmos

FILE

docker build . -t airflow_image

export AIRFLOW_PROJ_DIR=/opt/airflow/

mkdir -p /opt/airflow/

systemd-run --unit=sync-airflow-dags --on-boot=1 --on-unit-active=60 aws s3 sync s3://${var.airflow_s3_bucket}/${var.airflow_dags_s3_prefix} /opt/airflow/dags/

echo 'POSTGRES_USER=airflow' >> /root/.env
echo 'POSTGRES_PASSWORD=airflow' >> /root/.env
echo 'POSTGRES_DB=airflow'>> /root/.env
echo 'AIRFLOW__CORE__FERNET_KEY=' >> /root/.env
echo 'AIRFLOW__CORE__EXECUTOR=LocalExecutor' >> /root/.env
echo 'AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=True' >> /root/.env
echo 'AIRFLOW__CORE__LOAD_EXAMPLES=False' >> /root/.env
echo 'AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=False' >> /root/.env
echo 'AIRFLOW_UID=0' >> /root/.env
echo 'AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow' >> /root/.env
echo 'AIRFLOW__DATABASE__LOAD_DEFAULT_CONNECTIONS=False' >> /root/.env
echo '_AIRFLOW_DB_UPGRADE=True' >> /root/.env
echo '_AIRFLOW_WWW_USER_CREATE=True' >> /root/.env
echo '_AIRFLOW_WWW_USER_USERNAME=airflow' >> /root/.env
echo '_AIRFLOW_WWW_USER_PASSWORD=${random_password.airflow_admin_password.result}' >> /root/.env

docker-compose up airflow-init
EOF
}

module "airflow" {
    source =  "../docker_compose_on_ec2"
    name = "airflow"
    key_name = var.ssh_keypair
    instance_type = "t4g.medium"
    before_docker_compose_script = local.startup_script
    docker_compose_str = file("${path.module}/docker-compose.yml")
    iam_instance_profile = aws_iam_instance_profile.airflow_profile.name
    subnet_id = var.subnet_id
    availability_zone = var.availability_zone
    vpc_security_group_ids = var.security_group_ids
    associate_public_ip_address = true
    persistent_volume_size_gb = 1
}


