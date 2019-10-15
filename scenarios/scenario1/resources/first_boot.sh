#!/usr/bin/env bash
file=/etc/ssh/sshd_config
cp -p $file $file.old &&
while read key other
do
 case $key in
 GatewayPorts) other=yes;;
 AllowTcpForwarding) other=yes;;
 PubkeyAuthentication) other=yes;;
 PermitTunnel) other=yes;;
 esac
 echo "$key $other"
done < $file.old > $file
echo 'UseDNS no' >> $file
sudo service sshd restart
