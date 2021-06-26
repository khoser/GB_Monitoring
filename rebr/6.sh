#!/bin/sh

echo "
  - job_name: 'data'
    file_sd_configs:
    - files:
      - '/etc/prom-targets/*.json'
      refresh_interval: 10s
" >> /opt/prometheus/prometheus.yml

service prometheus restart
service prometheus status

mkdir /etc/prom-targets

echo '
[
  {
    "targets": [
       "192.168.0.100:9100",
       "192.168.0.200:9100"
    ],
    "labels": {
       "env": "dev"
    }
  }
]
' > /etc/prom-targets/dd.json

