#!/usr/bin/env bash
influx_url="https://csm.outcatcher.com/influxdb"
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

function install_telegraf() {
  echo 'deb https://repos.influxdata.com/debian stretch stable' | sudo tee /etc/apt/sources.list.d/influxdata.list
  sudo curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
  sudo apt-get update
  sudo apt-get -y install telegraf
  configure_telegraf
  sudo systemctl enable --now start telegraf || true
}

function configure_telegraf() {
  echo '
  # Telegraf configuration
  [agent]
    interval = "10s"
    round_interval = true
    metric_batch_size = 1000
    metric_buffer_limit = 10000
    collection_jitter = "0s"
    flush_interval = "10s"
    flush_jitter = "0s"

    ## Run telegraf in debug mode
    debug = false
    ## Run telegraf in quiet mode
    quiet = false

    omit_hostname = false

  ###############################################################################
  #                                  OUTPUTS                                    #
  ###############################################################################

  [outputs]
  [[outputs.influxdb]]
    urls = [ '\"${influx_url}\"' ] # required
    database = "telegraf" # required
    precision = "s"
    retention_policy = "autogen"
    write_consistency = "any"

    timeout = "5s"
    # Set the user agent for HTTP POSTs (can be useful for log differentiation)
    # Set UDP payload size, defaults to InfluxDB UDP Client default (512 bytes)

  ###############################################################################
  #                                  PLUGINS                                    #
  ###############################################################################

  [[inputs.mem]]
  [[inputs.cpu]]
      fielddrop = [ "time_*" ]
      totalcpu = true
      percpu = false
  [[inputs.procstat]]
      prefix = "influxdb"
      exe = "influxd"
  [[inputs.net]]
  ' > /etc/telegraf/telegraf.conf
}

function install_nginx() {
  sudo apt-get install nginx -y
  sudo systemctl enable nginx
  sudo apt-get install nginx-extras -y
}

install_telegraf
sudo service telegraf restart
install_nginx
sudo sed -i '/listen \[::\]:80 default_server;/a add_header Host $hostname;' /etc/nginx/sites-enabled/default
sudo sed -i '/types_hash_max_size/a more_clear_headers Server;' /etc/nginx/nginx.conf
sudo service nginx restart