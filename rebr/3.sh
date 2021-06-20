#!/bin/sh

apt install mysql-server
mysql -u root -e 'CREATE USER IF NOT EXISTS exporter@%'

mysql -u root -e ' SET PASSWORD FOR exporter@% = "bar"'

mysql -u root -e ' GRANT ALL ON *.* TO exporter@%'

mysql -u root -e ' FLUSH PRIVILEGES'

cd /opt/
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.13.0/mysqld_exporter-0.13.0.linux-amd64.tar.gz
tar -xzf mysqld_exporter-0.13.0.linux-amd64.tar.gz
mv mysqld_exporter-0.13.0.linux-amd64 mysqld_exporter
rm mysqld_exporter-0.13.0.linux-amd64.tar.gz
#chown -R monitoring:monitoring node_exporter

echo '
[Unit]
Description=Mysqld Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/opt/mysqld_exporter/mysqld_exporter \
	--web.listen-address=:9111 \
	--web.telemetry-path=/metrics

[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/mysqld_exporter.service

echo '
[mysqld_exporter]
user=exporter
password="bar"
[client]
user=exporter
password="bar"
' > /root/.my.cnf

systemctl enable mysqld_exporter
service mysqld_exporter start
service mysqld_exporter status

echo "

  - job_name: 'mysqld'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9111']
        labels:
          env: 'dev'
" >> /opt/prometheus/prometheus.yml

service prometheus restart
service prometheus status

