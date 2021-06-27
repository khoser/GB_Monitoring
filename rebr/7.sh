#!/bin/sh

echo "

  - job_name: 'node'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
        labels:
          env: 'dev'
" >> /opt/prometheus/prometheus.yml

service prometheus restart
service prometheus status

cd /opt/
wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz
tar -xzf node_exporter-1.1.2.linux-amd64.tar.gz
mv node_exporter-1.1.2.linux-amd64 node_exporter
rm node_exporter-1.1.2.linux-amd64.tar.gz

echo '
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/opt/node_exporter/node_exporter \
    --collector.interrupts

[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/node_exporter.service
systemctl enable node_exporter
service node_exporter start
service node_exporter status

echo '
sum by (instance) (irate(node_cpu_seconds_total{mode="user"}[2m]))
' > /tmp/query1.txt

echo '
node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"} * 100
' > /tmp/query2.txt
