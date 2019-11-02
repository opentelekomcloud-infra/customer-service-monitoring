#!/usr/bin/env bash
sudo systemctl enable nginx
sudo sed -i '/listen \[::\]:80 default_server;/a add_header Server $hostname;' /etc/nginx/sites-enabled/default
sudo sed -i '/types_hash_max_size/a more_clear_headers Server;' /etc/nginx/nginx.conf
sudo service nginx restart