
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_ami" "ubuntu_arm64" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}


# data "aws_ami" "al2_arm64" {
#   most_recent = true

#   owners = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-arm64-ebs"]
#   }  
# }

# resource "aws_instance" "private_ec2" {
#   instance_type = "t4g.nano"
#   ami = data.aws_ami.ubuntu_arm64.id
#   subnet_id = module.vpc.private_subnets[0]
#   vpc_security_group_ids = [module.vpc.default_security_group_id]
#   key_name = aws_key_pair.ssh.key_name
#   disable_api_termination = false
#   ebs_optimized = false
#   root_block_device {
#     volume_size = "10"
#   }

#   tags = {
#     "Name" = "private-instance"
#   }
# }


# resource "aws_instance" "mlflow_instance" {
#   instance_type = "t4g.micro"
#   ami = data.aws_ami.al2_arm64.id
#   subnet_id = module.vpc.public_subnets[0]
#   vpc_security_group_ids = [module.vpc.default_security_group_id]
#   key_name = aws_key_pair.ssh.key_name
#   disable_api_termination = false
#   ebs_optimized = false
#   root_block_device {
#     volume_size = "10"
#   }

#   user_data = <<EOF
# #! /bin/sh
# yum update -y
# amazon-linux-extras install docker
# service docker start
# usermod -a -G docker ec2-user
# chkconfig docker on

# EOF

#   tags = {
#     "Name" = "mlflow-instance"
#   }
# }




# https://github.com/kgmcquate/airflow.git