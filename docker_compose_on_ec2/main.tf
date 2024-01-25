locals {
    user_data = <<EOF
#!/bin/bash
set -Eeuxo pipefail

# Filesystem code is over
# Now we install docker and docker-compose.
# Adapted from:
# https://gist.github.com/npearce/6f3c7826c7499587f00957fee62f8ee9
yum update -y

yum install -y docker
systemctl start docker.service
usermod -a -G docker ec2-user
chkconfig docker on
docker --version

sudo curl -sL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-aarch64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# Put the docker-compose.yml file at the root of our persistent volume
cat > $DEST/docker-compose.yml <<-TEMPLATE
${var.docker_compose_str}
TEMPLATE

# Write the systemd service that manages us bringing up the service
cat > /etc/systemd/system/my_custom_service.service <<-TEMPLATE
[Unit]
Description=${var.description}
After=${var.systemd_after_stage}
[Service]
Type=simple
User=${var.user}
ExecStart=/usr/local/bin/docker-compose -f $DEST/docker-compose.yml up
Restart=on-failure
[Install]
WantedBy=multi-user.target
TEMPLATE

# Start the service.
systemctl start my_custom_service
EOF
}

data "aws_ami" "al_arm64" {
  most_recent = true

  filter {
    name = "name"
    values = ["al2023-ami-*-kernel-*-arm64"]
  }
  owners = ["amazon"]
}

# resource "aws_ebs_volume" "persistent" {
#     availability_zone = aws_instance.this.availability_zone
#     size = var.persistent_volume_size_gb
# }

# resource "aws_volume_attachment" "persistent" {
#     device_name = local.block_device_path
#     volume_id = aws_ebs_volume.persistent.id
#     instance_id = aws_instance.this.id
# }

resource "aws_instance" "this" {
    ami = data.aws_ami.al_arm64.id
    availability_zone = var.availability_zone
    instance_type = var.instance_type
    key_name = var.key_name
    associate_public_ip_address = var.associate_public_ip_address
    vpc_security_group_ids = var.vpc_security_group_ids
    subnet_id = var.subnet_id
    iam_instance_profile = var.iam_instance_profile
    user_data = local.user_data
    tags = merge (
        {
            Name = var.name
        },
        var.tags
    )
}