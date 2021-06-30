#!/bin/sh

echo '

rule_files:
  - "alerts.yml"
' >> /opt/prometheus/prometheus.yml

service prometheus restart
service prometheus status

cd /opt/prometheus

echo '
groups:
- name: CompactionTimeTooLong
  interval: 10s
  rules:
  - alert: prometheus_tsdb_compaction_duration_seconds_bucket
    expr: up == 0
    for: 5m
    labels:
      severity: warning
      env: dev
    annotations:
      summary: Comaction time on {{ $labels.instance }} equals {{ $value }}.
' >> /opt/prometheus/alerts.yml

histogram_quantile(0.95, (prometheus_tsdb_compaction_duration_seconds_bucket[10m] ) )