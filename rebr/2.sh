#!/bin/sh

useradd -s /sbin/nologin -d /opt/monitoring monitoring
cd /opt/
wget  https://github.com/prometheus/prometheus/releases/download/v2.27.1/prometheus-2.27.1.linux-amd64.tar.gz
tar -xzf prometheus-2.27.1.linux-amd64.tar.gz
mv prometheus-2.27.1.linux-amd64 prometheus
rm prometheus-2.27.1.linux-amd64.tar.gz
chown -R monitoring:monitoring prometheus
cd prometheus/
mkdir /var/lib/prometheus/
chown -R monitoring:monitoring /var/lib/prometheus/
# mv prometheus /usr/local/bin/
# mkdir /etc/prometheus
# chown -R monitoring:monitoring /etc/prometheus
# mv prometheus.yml /etc/prometheus/
# sed -e 's/localhost:9090/localhost:9191/g' prometheus.yml > /etc/prometheus/prometheus.yml
echo "

  - job_name: 'node'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
        labels:
          env: 'dev'
" >> prometheus.yml

echo '
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=monitoring
Group=monitoring
ExecStart=/opt/prometheus/prometheus \
	--config.file=/opt/prometheus/prometheus.yml \
	--storage.tsdb.path=/var/lib/prometheus/data \
	--web.console.templates=/opt/prometheus/consoles \
	--web.console.libraries=/opt/prometheus/console_libraries \
	--web.listen-address="0.0.0.0:9090"

[Install]
WantedBy=default.target
' > /etc/systemd/system/prometheus.service
systemctl enable prometheus
service prometheus start
service prometheus status

cd /opt/
wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz
tar -xzf node_exporter-1.1.2.linux-amd64.tar.gz
mv node_exporter-1.1.2.linux-amd64 node_exporter
rm node_exporter-1.1.2.linux-amd64.tar.gz
chown -R monitoring:monitoring node_exporter

echo '
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=monitoring
Group=monitoring
Type=simple
ExecStart=/opt/node_exporter/node_exporter \
    --collector.interrupts

[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/node_exporter.service
systemctl enable node_exporter
service node_exporter start
service node_exporter status
