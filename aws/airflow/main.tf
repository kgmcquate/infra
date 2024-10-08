variable subnet_id {}
variable security_group_ids {}
variable availability_zone {}
variable ssh_keypair {}
variable domain {}
variable airflow_s3_bucket {}
variable airflow_dags_s3_prefix {
    default = "airflow/dags/"
}
variable posgtres_db_secret_name {}

data "aws_secretsmanager_secret" "postgres_creds" {
  name = var.posgtres_db_secret_name
}
data "aws_secretsmanager_secret_version" "postgres_creds" {
  secret_id = data.aws_secretsmanager_secret.postgres_creds.id
}

locals {
    postgres_secret = jsondecode(data.aws_secretsmanager_secret_version.postgres_creds.secret_string)
    postgres_username = local.postgres_secret["username"]
    postgres_password = local.postgres_secret["password"]
    postgres_endpoint = local.postgres_secret["host"]
    # echo 'AIRFLOW_CONN_REDSHIFT=redshift://my-db:5439/db_client?user=airflow-user&password=XXXXXXXX'
    startup_script = <<-EOF
cat > Dockerfile <<-"FILE"
FROM apache/airflow:2.8.1-python3.11

USER root
RUN mkdir -p /opt/airflow/logs/ &&  \
    mkdir -p /opt/airflow/logs/scheduler &&  \
    mkdir -p /opt/airflow/dags/ &&  \
    mkdir -p /opt/airflow/plugins/ &&  \
    chmod 777 -R /opt/airflow/ &&  \
    mkdir -p /sources/logs/ &&  \
    mkdir -p /sources/dags/ &&  \
    mkdir -p /sources/plugins/ &&  \
    chmod 777 -R /sources/

USER airflow
RUN pip install astronomer-cosmos dbt-core dbt-postgres \
        apache-airflow==2.8.1 \
        pydantic>=2.3.0 \
        urllib3==1.26.18 \
        boto3==1.34.29 \
        opencv-python-headless==4.9.0.80 \
        av==11.0.0 \
        streamlink==6.5.1 \
        m3u8==4.0.0 \
        fastavro \
        numpy==1.26.3 \
        pulsar-client==3.4.0 \
        sqlalchemy==1.4.51 \
        psycopg2-binary \
        confluent-kafka==2.5.3

FILE

docker build . -t airflow_image

export AIRFLOW_PROJ_DIR=/opt/airflow/

mkdir -p /opt/airflow/
mkdir -p /opt/airflow/logs/
mkdir -p /opt/airflow/logs/scheduler/
mkdir -p /opt/airflow/dags/
mkdir -p /opt/airflow/plugins/
chmod -R 777 /opt/airflow/
chmod -R 777 /tmp/

systemd-run --unit=sync-airflow-dags --on-boot=1 --on-unit-active=60 aws s3 sync s3://${var.airflow_s3_bucket}/${var.airflow_dags_s3_prefix} /opt/airflow/dags/

# echo -e "AIRFLOW_UID=$(id -u)" >> .env

echo -e "AIRFLOW_UID=50000" >> .env
echo 'AIRFLOW_CONN_POSTGRES=postgresql://${local.postgres_username}:${local.postgres_password}@${local.postgres_endpoint}/postgres' >> /root/.env

echo 'AIRFLOW_CONN_AWS_DEFAULT=aws://' >> /root/.env
echo 'POSTGRES_USER=airflow' >> /root/.env
echo 'POSTGRES_PASSWORD=airflow' >> /root/.env
echo 'POSTGRES_DB=airflow'>> /root/.env
echo 'AIRFLOW__CORE__FERNET_KEY=' >> /root/.env
echo 'AIRFLOW__CORE__EXECUTOR=LocalExecutor' >> /root/.env
echo 'AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=True' >> /root/.env
echo 'AIRFLOW__CORE__LOAD_EXAMPLES=False' >> /root/.env
echo 'AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=False' >> /root/.env
echo 'AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow' >> /root/.env
echo 'AIRFLOW__DATABASE__LOAD_DEFAULT_CONNECTIONS=False' >> /root/.env
echo '_AIRFLOW_DB_MIGRATE=True' >> /root/.env
echo '_AIRFLOW_WWW_USER_CREATE=True' >> /root/.env
echo '_AIRFLOW_WWW_USER_USERNAME=airflow' >> /root/.env
echo '_AIRFLOW_WWW_USER_PASSWORD=${random_password.airflow_admin_password.result}' >> /root/.env

docker-compose up airflow-init
EOF
}

module "airflow" {
    source =  "./../../docker_compose_on_ec2"
    name = "airflow"
    key_name = var.ssh_keypair
    instance_type = "t4g.large"
    before_docker_compose_script = local.startup_script
    docker_compose_str = file("${path.module}/docker-compose.yml")
    iam_instance_profile = aws_iam_instance_profile.airflow_profile.name
    subnet_id = var.subnet_id
    availability_zone = var.availability_zone
    vpc_security_group_ids = var.security_group_ids
    associate_public_ip_address = true
    persistent_volume_size_gb = 1
}