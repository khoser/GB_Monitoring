#!/bin/sh

useradd -s /sbin/nologin -d /opt/monitoring monitoring
cd /opt/
wget  https://github.com/prometheus/prometheus/releases/download/v2.27.1/prometheus-2.27.1.linux-amd64.tar.gz
tar -xzf prometheus-2.27.1.linux-amd64.tar.gz
mv prometheus-2.27.1.linux-amd64 prometheus
sudo chown -R monitoring:monitoring prometheus
cd prometheus/
mv prometheus /usr/local/bin/
mkdir /etc/prometheus
chown -R monitoring:monitoring /etc/prometheus
# mv prometheus.yml /etc/prometheus/
sed -e 's/localhost:9090/localhost:9191/g' prometheus.yml > /etc/prometheus/prometheus.yml
echo '
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=monitoring
Group=monitoring
ExecStart=/usr/local/bin/prometheus \
	--config.file=/etc/prometheus/prometheus.yml \
	--storage.tsdb.path=/var/lib/prometheus/data \
	--web.console.templates=/etc/prometheus/consoles \
	--web.console.libraries=/etc/prometheus/console_libraries \
	--web.listen-address="0.0.0.0:9191" 

[Install]
WantedBy=default.target
' > /etc/systemd/system/prometheus.service
mkdir /var/lib/prometheus/
chown -R monitoring:monitoring /var/lib/prometheus/
mv /opt/prometheus/consol* /etc/prometheus/
systemctl enable prometheus
service prometheus start
service prometheus status