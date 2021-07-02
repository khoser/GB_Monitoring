#!/bin/sh

echo '

rule_files:
  - "alerts.yml"
' >> /opt/prometheus/prometheus.yml

cd /opt/prometheus

echo '
groups:
- name: CompactionTimeTooLong
  interval: 10s
  rules:
  - alert: prometheus_tsdb_compaction_duration_seconds_bucket
    expr: histogram_quantile(0.95, (prometheus_tsdb_compaction_duration_seconds_bucket[10m] ) ) >= 1
    for: 5m
    labels:
      severity: warning
      env: dev
    annotations:
      summary: Comaction time on {{ $labels.instance }} equals {{ $value }}.
' >> /opt/prometheus/alerts.yml

service prometheus restart
service prometheus status
