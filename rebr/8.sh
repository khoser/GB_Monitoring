#!/bin/sh

cd /opt/
echo "

  - job_name: 'redis'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9121']
        labels:
          env: 'dev'
" >> /opt/prometheus/prometheus.yml

service prometheus restart
service prometheus status

cd /opt/
wget https://github.com/oliver006/redis_exporter/releases/download/v1.24.0/redis_exporter-v1.24.0.linux-amd64.tar.gz
tar -xzf redis_exporter-v1.24.0.linux-amd64.tar.gz
mv redis_exporter-v1.24.0.linux-amd64 redis_exporter
rm redis_exporter-v1.24.0.linux-amd64.tar.gz

echo '
[Unit]
Description=Redis Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/opt/redis_exporter/redis_exporter \

[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/redis_exporter.service
systemctl enable redis_exporter
service redis_exporter start
service redis_exporter status

apt update && apt upgrade -y
apt install -y apt-transport-https
apt install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
deb https://packages.grafana.com/oss/deb stable main
apt update
apt install grafana redis-server -y

[security]
admin_user = admin
admin_password = secretpassword


