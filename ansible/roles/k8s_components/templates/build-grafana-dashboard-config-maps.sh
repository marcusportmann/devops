#!/bin/sh
#
# xattr -d com.apple.quarantine build-grafana-dashboard-config-maps.sh 
#

> grafana-dashboard-config-maps.yaml.j2

echo "{% raw %}" >> grafana-dashboard-config-maps.yaml.j2

dashboard_file_json=`cat grafana-dashboards/kubernetes-nodes-dashboard.json | jq -c`

cat <<EOT >> grafana-dashboard-config-maps.yaml.j2
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard-kubernetes-nodes-dashboard
  namespace: monitoring-system
  labels:
    grafana_dashboard: kubernetes-nodes-dashboard.json
data: 
  kubernetes-nodes-dashboard.json: |- 
    $dashboard_file_json
---
EOT




echo "{% endraw %}" >> grafana-dashboard-config-maps.yaml.j2
