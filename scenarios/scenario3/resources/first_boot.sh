#!/usr/bin/env bash
#setup ssh service config
file=/etc/ssh/sshd_config
cp -p $${file} $${file}.old &&
while read key other
do
 case $${key} in
 GatewayPorts) other=yes;;
 AllowTcpForwarding) other=yes;;
 PubkeyAuthentication) other=yes;;
 PermitTunnel) other=yes;;
 esac
 echo "$key $other"
done < $${file}.old > $${file}
sudo service sshd restart
