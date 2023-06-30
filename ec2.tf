resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name = "ec2_ssh_key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_secretsmanager_secret" "ec2_ssh_private_key" {
   name = "ec2_ssh_private_key"
}

# Store private key in secretsmanager for later access
resource "aws_secretsmanager_secret_version" "private_key_version" {
  secret_id = aws_secretsmanager_secret.ec2_ssh_private_key.id
  secret_string = tls_private_key.ssh.private_key_pem
}

resource "aws_security_group" "ec2securitygroup" {
  name = "ec2securitygroup"
  description = "ec2securitygroup"
  vpc_id = aws_default_vpc.default.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}


resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_default_vpc.default.id}"
}

resource "aws_route" "private_nat_instance" {
  route_table_id         = "${aws_route_table.private_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id = aws_instance.ec2instance.primary_network_interface_id
}


# https://kenhalbert.com/posts/creating-an-ec2-nat-instance-in-aws
resource "aws_instance" "ec2instance" {
  instance_type = "t2.micro"
  ami = data.aws_ami.ubuntu.id
  subnet_id = aws_subnet.private_subnet[0].id
  security_groups = [aws_security_group.ec2securitygroup.id]
  key_name = aws_key_pair.ssh.key_name
  disable_api_termination = false
  ebs_optimized = false
  root_block_device {
    volume_size = "10"
  }

  # Add NAT gateway routing
  user_data = <<EOT
#!/bin/bash
sudo /usr/bin/apt update
sudo /usr/bin/apt install ifupdown
/bin/echo '#!/bin/bash
if [[ $(sudo /usr/sbin/iptables -t nat -L) != *"MASQUERADE"* ]]; then
  /bin/echo 1 > /proc/sys/net/ipv4/ip_forward
  /usr/sbin/iptables -t nat -A POSTROUTING -s ${aws_default_vpc.default.cidr_block} -j MASQUERADE
fi
' | sudo /usr/bin/tee /etc/network/if-pre-up.d/nat-setup
sudo chmod +x /etc/network/if-pre-up.d/nat-setup
sudo /etc/network/if-pre-up.d/nat-setup 
  EOT

}
