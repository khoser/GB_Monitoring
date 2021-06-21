#!/bin/sh

cd /opt/
wget https://github.com/prometheus/pushgateway/releases/download/v1.4.1/pushgateway-1.4.1.linux-amd64.tar.gz
tar -xzf pushgateway-1.4.1.linux-amd64.tar.gz
mv pushgateway-1.4.1.linux-amd64 pushgateway
cd pushgateway

echo '
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
ExecStart=/opt/pushgateway/pushgateway \
    --web.listen-address=:9991 \
    --persistence.file=/opt/pushgateway/pushgateway.metrics

[Install]
WantedBy=default.target
' > /etc/systemd/system/pushgateway.service
systemctl enable pushgateway
service pushgateway start
service pushgateway status

echo "

  - job_name: 'whoami'
    scrape_interval: 15s
    honor_labels: true
    static_configs:
      - targets: ['localhost:9991']
        labels:
          env: 'app'
" >> /opt/prometheus/prometheus.yml

service prometheus restart
service prometheus status

#echo "time_run 3.14" | curl --data-binary @- http://localhost:9991/metrics/job/test1/instance/app1
#echo "time_run 6.18" | curl --data-binary @- http://localhost:9991/metrics/job/test1/instance/app2

cat <<EOF | curl --data-binary @- http://localhost:9991/metrics/job/test1/instance/app1
# TYPE time_run gauge
time_run 3.14
EOF

cat <<EOF | curl --data-binary @- http://localhost:9991/metrics/job/test1/instance/app2
# TYPE time_run gauge
time_run 6.18
EOF

