#!/bin/sh

#check prometheus.yml:
#alerting:
#  alertmanagers:
#  - static_configs:
#    - targets:
#      - localhost:9093

mv /opt/prometheus/prometheus.yml /opt/prometheus/prometheus_bac.yml

sed 's/rule_files:/rule_files:\n  - "alerts.yml"/g' /opt/prometheus/prometheus_bac.yml > /opt/prometheus/prometheus.yml

echo '
groups:
- name: InstanceDown
  interval: 10s
  rules:
  - alert: InstanceDown
    expr: up == 0
    labels:
      severity: critical
    annotations:
      summary: Instance is down!
' > /opt/prometheus/alerts.yml

service prometheus restart
service prometheus status

cd /opt/
wget https://github.com/prometheus/alertmanager/releases/download/v0.22.2/alertmanager-0.22.2.linux-amd64.tar.gz
tar -xzf alertmanager-0.22.2.linux-amd64.tar.gz
mv alertmanager-0.22.2.linux-amd64 alertmanager
rm alertmanager-0.22.2.linux-amd64.tar.gz


echo "
global:
  smtp_smarthost: 'mail.kter.ru:587'
  smtp_from: 'test@kter.ru'
  smtp_auth_username: 'test@kter.ru'
  smtp_auth_password: '123456'

route:
  group_by: ['alertname']
  group_wait: 0s
  group_interval: 1m
  repeat_interval: 5m
  receiver: 'email'

receivers:
- name: 'email'
  email_configs:
  - to: 'test@kter.ru'

    #route:
    #  group_by: ['alertname']
    #  group_wait: 0s
    #  group_interval: 1m
    #  repeat_interval: 5m
    #  receiver: 'email'
    #
    #receivers:
    #- name: 'email'
    #  email_configs:
    #  - to: "test@kter.ru"
    #  - smarthost: 'mail.kter.ru:587'
    #  - auth_username: 'test@kter.ru'
    #  - auth_password: '123456'

" > /opt/alertmanager/alertmanager.yml

echo '
[Unit]
Description=alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/opt/alertmanager/alertmanager \
      --config.file=/opt/alertmanager/alertmanager.yml

[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/alertmanager.service

systemctl enable alertmanager
service alertmanager start
service alertmanager status

