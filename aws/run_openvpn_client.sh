#yum -y install https://as-repository.openvpn.net/as-repo-amzn2.rpm
#yum -y install openvpn-as

amazon-linux-extras install -y epel
yum -y install openvpn

aws secretsmanager get-secret-value --region us-east-1 --secret-id openvpn-config --query SecretString --output text > client.ovpn
cp client.ovpn /etc/openvpn/client.conf
#openvpn --config client.ovpn
systemctl enable openvpn@client.service
service openvpn@client start
