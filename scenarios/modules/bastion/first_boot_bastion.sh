#!/usr/bin/env bash
#setup ssh service config
file=/etc/ssh/sshd_config
cp -p $\{file} $\{file}.old &&
while read key other
do
 case $\{key} in
 GatewayPorts) other=yes;;
 AllowTcpForwarding) other=yes;;
 PubkeyAuthentication) other=yes;;
 PermitTunnel) other=yes;;
 esac
 echo "$key $other"
done < $\{file}.old > $\{file}
sudo service sshd restart

#enable port forwarding
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

#configure SNAT
sudo iptables -t nat -A POSTROUTING -o eth0 -s ${addr_3_octets}.0/16 -j SNAT --to ${addr_3_octets}.2

#generate Diffie-Hellman for TLS
sudo openssl dhparam -out /etc/sslcerts/live/dhparams.pem 2048
