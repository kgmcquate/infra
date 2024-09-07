yum -y install https://as-repository.openvpn.net/as-repo-amzn2.rpm
yum -y install openvpn-as

aws secretsmanager get-secret-value --secret-id openvpn-config --query SecretString --output text | jq -r .openvpn > client.ovpn
openvpn --config client.ovpn