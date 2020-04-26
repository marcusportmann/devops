#!/bin/sh
#
# xattr -d com.apple.quarantine build-istio-grafana-dashboard-config-maps.sh 
#

> istio-grafana-dashboard-config-maps.yaml.j2

echo "{% raw %}" >> istio-grafana-dashboard-config-maps.yaml.j2

declare -a istio_dashboard_files=("istio-mesh-dashboard.json" "istio-performance-dashboard.json" "istio-service-dashboard.json" "istio-workload-dashboard.json")
 
# Iterate the string array using for loop
for istio_dashboard_file in ${istio_dashboard_files[@]}; do
  istio_dashboard_file_url="https://raw.githubusercontent.com/istio/istio/release-1.5/manifests/istio-telemetry/grafana/dashboards/$istio_dashboard_file"
  istio_dashboard_file_json=`curl -s $istio_dashboard_file_url | jq -c`
    
  if [ "$?" != "0" ]; then    
   echo "Failed to process the Istio Grafana dashboard file $istio_dashboard_file"
   echo $istio_dashboard_file_json > "$istio_dashboard_file.error"
  fi
  
   istio_dashboard_name=${istio_dashboard_file%.*} 
   

cat <<EOT >> istio-grafana-dashboard-config-maps.yaml.j2
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard-$istio_dashboard_name
  namespace: monitoring-system
  labels:
    grafana_dashboard: $istio_dashboard_file
data: 
  $istio_dashboard_file: |- 
    $istio_dashboard_file_json
---
EOT
done



echo "{% endraw %}" >> istio-grafana-dashboard-config-maps.yaml.j2
