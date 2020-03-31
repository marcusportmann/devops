#!/bin/sh
#
# xattr -d com.apple.quarantine build-k8s-grafana-dashboard-config-maps.sh 
#

> k8s-grafana-dashboard-config-maps.yaml.j2

echo "{% raw %}" >> k8s-grafana-dashboard-config-maps.yaml.j2



dashboard_file_json=`cat grafana-dashboards/k8s-nodes-dashboard.json | jq -c`

cat <<EOT >> k8s-grafana-dashboard-config-maps.yaml.j2
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard-k8s-nodes-dashboard
  namespace: monitoring-system
  labels:
    grafana_dashboard: k8s-nodes-dashboard.json
data: 
  k8s-nodes-dashboard.json: |- 
    $dashboard_file_json
---
EOT


# From: https://grafana.com/grafana/dashboards/11145

dashboard_file_json=`cat grafana-dashboards/k8s-deployments-dashboard.json | jq -c`

cat <<EOT >> k8s-grafana-dashboard-config-maps.yaml.j2
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard-k8s-deployments-dashboard
  namespace: monitoring-system
  labels:
    grafana_dashboard: k8s-deployments-dashboard.json
data: 
  k8s-deployments-dashboard.json: |- 
    $dashboard_file_json
---
EOT



# From: https://grafana.com/grafana/dashboards/11143

dashboard_file_json=`cat grafana-dashboards/k8s-apps-dashboard.json | jq -c`

cat <<EOT >> k8s-grafana-dashboard-config-maps.yaml.j2
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard-k8s-apps-dashboard
  namespace: monitoring-system
  labels:
    grafana_dashboard: k8s-apps-dashboard.json
data: 
  k8s-apps-dashboard.json: |- 
    $dashboard_file_json
---
EOT


# From: https://grafana.com/grafana/dashboards/11142

dashboard_file_json=`cat grafana-dashboards/k8s-pods-dashboard.json | jq -c`

cat <<EOT >> k8s-grafana-dashboard-config-maps.yaml.j2
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard-k8s-pods-dashboard
  namespace: monitoring-system
  labels:
    grafana_dashboard: k8s-pods-dashboard.json
data: 
  k8s-pods-dashboard.json: |- 
    $dashboard_file_json
---
EOT


# From: https://grafana.com/grafana/dashboards/11144

dashboard_file_json=`cat grafana-dashboards/k8s-cluster-dashboard.json | jq -c`

cat <<EOT >> k8s-grafana-dashboard-config-maps.yaml.j2
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard-k8s-cluster-dashboard
  namespace: monitoring-system
  labels:
    grafana_dashboard: k8s-cluster-dashboard.json
data: 
  k8s-cluster-dashboard.json: |- 
    $dashboard_file_json
---
EOT



echo "{% endraw %}" >> k8s-grafana-dashboard-config-maps.yaml.j2
