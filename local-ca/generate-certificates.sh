#!/bin/sh

# Execute the following command to allow the script to be executed on MacOS:
#   xattr -d com.apple.quarantine generate-certificates.sh

# NOTE: All certificates follow one of the following naming conventions:
#
#         1. <platform>-<platform_instance_name_or_cluster_name>-<environment>
#
#              e.g. etcd-local
#
#         2. <platform>-<platform_instance_name_or_cluster_name>-<platform_component_or_role>
#
#              e.g. k8s-local-dev-topolvm-mutatingwebhook where the <platform> is k8s, the
#                   <platform_instance_name_or_cluster_name> is local, and the
#                   <platform_component_or_role> is topolvm-mutatingwebhook
#
#                   k8s-local-dev-kibana where the <platform> is k8s, the
#                   <platform_instance_name_or_cluster_name> is local, and the
#                   <platform_component_or_role> is kibana
#
#                   k8s-digital-prod-elasticsearch where the <platform> is k8s, the
#                   <platform_instance_name_or_cluster_name> is digital-prod, and the
#                   <platform_component_or_role> is elasticsearch
#
#         3. <hostname>, where <hostname> is normally made up of
#            <platform>-<platform_instance_name_or_cluster_name>-<instance_id>
#
#              e.g. kafka-local-dev-01 where the <instance_id> is 01
#
#         4. <hostname>-<purpose>, where <hostname> is normally made up of
#            <platform>-<platform_instance_name_or_cluster_name>-<instance_id>
#
#              e.g. etcd-local-dev-01-etcd-peer where the <purpose> is etcd-peer



# find . -name "*.crt" -exec git rm -f {} \;
# find . -name "*.crt" -exec rm -f {} \;
# find . -name "*.key" -exec git rm -f {} \;
# find . -name "*.key" -exec rm -f {} \;
# find . -name "*.csr" -exec git rm -f {} \;
# find . -name "*.csr" -exec rm -f {} \;
# find . -name "*.pem" -exec git rm -f {} \;
# find . -name "*.pem" -exec rm -f {} \;
# find . -name "*.p12" -exec git rm -f {} \;
# find . -name "*.p12" -exec rm -f {} \;





mkdir -p ../ansible/roles/etcd/files/pki/local-dev
mkdir -p ../ansible/roles/k8s_common/files/pki/local-dev
mkdir -p ../ansible/roles/k8s_istio/files/pki/local-dev
mkdir -p ../ansible/roles/k8s_master/files/pki/local-dev
mkdir -p ../ansible/roles/k8s_monitoring/files/pki/local-dev
mkdir -p ../ansible/roles/k8s_operators/files/pki/local-dev
mkdir -p ../ansible/roles/k8s_storage/files/pki/local-dev
mkdir -p ../ansible/roles/kafka_mirrormaker/files/pki/local-dev
mkdir -p ../ansible/roles/kafka_server/files/pki/local-dev
mkdir -p ../ansible/roles/kafka_zookeeper/files/pki/local-dev


# Generate the Root CA private key and certificate
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
mv -f ca.pem ca.crt
mv -f ca-key.pem ca.key
rm -f ca.p12
keytool -importcert -noprompt -trustcacerts -alias "Local Root Certificate Authority (1)" -file ca.crt -keystore ca.p12 -storetype PKCS12 -storepass "ulLdVI9hUP46gaQj"
cp ca.crt ../ansible/roles/confluent_kafka_mirrormaker/files/pki/local-dev/ca.crt
cp ca.crt ../ansible/roles/confluent_kafka_server/files/pki/local-dev/ca.crt
cp ca.crt ../ansible/roles/confluent_zookeeper/files/pki/local-dev/ca.crt
cp ca.crt ../ansible/roles/etcd/files/pki/local-dev
cp ca.crt ../ansible/roles/k8s_common/files/pki/local-dev/ca.crt
cp ca.crt ../ansible/roles/k8s_istio/files/pki/local-dev/ca.crt
cp ca.crt ../ansible/roles/k8s_master/files/pki/local-dev/ca.crt
cp ca.crt ../ansible/roles/k8s_master/files/pki/local-dev/etcd-ca.crt
cp ca.crt ../ansible/roles/k8s_monitoring/files/pki/local-dev/ca.crt
cp ca.crt ../ansible/roles/k8s_operators/files/pki/local-dev/ca.crt
cp ca.crt ../ansible/roles/k8s_storage/files/pki/local-dev/ca.crt
cp ca.crt ../ansible/roles/k8s_storage/files/pki/local-dev/ca-bundle.crt
cp ca.crt ../ansible/roles/kafka_mirrormaker/files/pki/local-dev/ca.crt
cp ca.crt ../ansible/roles/kafka_server/files/pki/local-dev/ca.crt
cp ca.crt ../ansible/roles/kafka_zookeeper/files/pki/local-dev/ca.crt
cp ca.p12 ../demos/kafka/demo-producer/pki/ca.p12
cp ca.p12 ../demos/kafka/demo-consumer/pki/ca.p12


# Generate the Confluent hosts private keys and certificates
cfssl genkey confluent-local-dev-01-csr.json | cfssljson -bare confluent-local-dev-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-local-dev-01.csr | cfssljson -bare confluent-local-dev-01
mv -f confluent-local-dev-01-key.pem confluent-local-dev-01.key
mv -f confluent-local-dev-01.pem confluent-local-dev-01.crt
cp confluent-local-dev-01.key ../ansible/roles/confluent_zookeeper/files/pki/local-dev
cp confluent-local-dev-01.crt ../ansible/roles/confluent_zookeeper/files/pki/local-dev

cfssl genkey confluent-local-dev-02-csr.json | cfssljson -bare confluent-local-dev-02
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-local-dev-02.csr | cfssljson -bare confluent-local-dev-02
mv -f confluent-local-dev-02-key.pem confluent-local-dev-02.key
mv -f confluent-local-dev-02.pem confluent-local-dev-02.crt
cp confluent-local-dev-02.key ../ansible/roles/confluent_zookeeper/files/pki/local-dev
cp confluent-local-dev-02.crt ../ansible/roles/confluent_zookeeper/files/pki/local-dev

cfssl genkey confluent-local-dev-03-csr.json | cfssljson -bare confluent-local-dev-03
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-local-dev-03.csr | cfssljson -bare confluent-local-dev-03
mv -f confluent-local-dev-03-key.pem confluent-local-dev-03.key
mv -f confluent-local-dev-03.pem confluent-local-dev-03.crt
cp confluent-local-dev-03.key ../ansible/roles/confluent_zookeeper/files/pki/local-dev
cp confluent-local-dev-03.crt ../ansible/roles/confluent_zookeeper/files/pki/local-dev

cfssl genkey confluent-local-dev-04-csr.json | cfssljson -bare confluent-local-dev-04
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-local-dev-04.csr | cfssljson -bare confluent-local-dev-04
mv -f confluent-local-dev-04-key.pem confluent-local-dev-04.key
mv -f confluent-local-dev-04.pem confluent-local-dev-04.crt
cp confluent-local-dev-04.key ../ansible/roles/confluent_zookeeper/files/pki/local-dev
cp confluent-local-dev-04.crt ../ansible/roles/confluent_zookeeper/files/pki/local-dev

cfssl genkey confluent-local-dev-05-csr.json | cfssljson -bare confluent-local-dev-05
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-local-dev-05.csr | cfssljson -bare confluent-local-dev-05
mv -f confluent-local-dev-05-key.pem confluent-local-dev-05.key
mv -f confluent-local-dev-05.pem confluent-local-dev-05.crt
cp confluent-local-dev-05.key ../ansible/roles/confluent_zookeeper/files/pki/local-dev
cp confluent-local-dev-05.crt ../ansible/roles/confluent_zookeeper/files/pki/local-dev

cfssl genkey confluent-local-dev-06-csr.json | cfssljson -bare confluent-local-dev-06
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-local-dev-06.csr | cfssljson -bare confluent-local-dev-06
mv -f confluent-local-dev-06-key.pem confluent-local-dev-06.key
mv -f confluent-local-dev-06.pem confluent-local-dev-06.crt
cp confluent-local-dev-06.key ../ansible/roles/confluent_zookeeper/files/pki/local-dev
cp confluent-local-dev-06.crt ../ansible/roles/confluent_zookeeper/files/pki/local-dev


# Generate the Confluent Kafka Server certificate
cfssl genkey confluent-local-dev-kafka-server-csr.json | cfssljson -bare confluent-local-dev-kafka-server
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-local-dev-kafka-server.csr | cfssljson -bare confluent-local-dev-kafka-server
mv -f confluent-local-dev-kafka-server-key.pem confluent-local-dev-kafka-server.key
mv -f confluent-local-dev-kafka-server.pem confluent-local-dev-kafka-server.crt
cp confluent-local-dev-kafka-server.key ../ansible/roles/confluent_kafka_server/files/pki/local-dev
cp confluent-local-dev-kafka-server.crt ../ansible/roles/confluent_kafka_server/files/pki/local-dev


# Generate the Confluent Kafka MirrorMaker certificate
cfssl genkey confluent-local-dev-kafka-mirrormaker-csr.json | cfssljson -bare confluent-local-dev-kafka-mirrormaker
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-local-dev-kafka-mirrormaker.csr | cfssljson -bare confluent-local-dev-kafka-mirrormaker
mv -f confluent-local-dev-kafka-mirrormaker-key.pem confluent-local-dev-kafka-mirrormaker.key
mv -f confluent-local-dev-kafka-mirrormaker.pem confluent-local-dev-kafka-mirrormaker.crt
cp confluent-local-dev-kafka-mirrormaker.key ../ansible/roles/confluent_kafka_mirrormaker/files/pki/local-dev
cp confluent-local-dev-kafka-mirrormaker.crt ../ansible/roles/confluent_kafka_mirrormaker/files/pki/local-dev


# Generate the Confluent Kafka Admin certificate
cfssl genkey confluent-local-dev-kafka-admin-csr.json | cfssljson -bare confluent-local-dev-kafka-admin
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client confluent-local-dev-kafka-admin.csr | cfssljson -bare confluent-local-dev-kafka-admin
mv -f confluent-local-dev-kafka-admin-key.pem confluent-local-dev-kafka-admin.key
mv -f confluent-local-dev-kafka-admin.pem confluent-local-dev-kafka-admin.crt
cp confluent-local-dev-kafka-admin.key ../ansible/roles/confluent_kafka_server/files/pki/local-dev
cp confluent-local-dev-kafka-admin.crt ../ansible/roles/confluent_kafka_server/files/pki/local-dev


# Generate the etcd intermediate CA private key and certificate
cfssl gencert -initca etcd-local-dev-ca-csr.json | cfssljson -bare etcd-local-dev-ca
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile intermediate_ca etcd-local-dev-ca.csr | cfssljson -bare etcd-local-dev-ca
mv -f etcd-local-dev-ca-key.pem etcd-local-dev-ca.key
mv -f etcd-local-dev-ca.pem etcd-local-dev-ca.crt
cp etcd-local-dev-ca.crt ../ansible/roles/etcd/files/pki/local-dev
cp etcd-local-dev-ca.key ../ansible/roles/etcd/files/pki/local-dev


# Generate the Kubernetes intermediate CA private key and certificate
cfssl gencert -initca k8s-local-dev-ca-csr.json | cfssljson -bare k8s-local-dev-ca
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile intermediate_ca k8s-local-dev-ca.csr | cfssljson -bare k8s-local-dev-ca
mv -f k8s-local-dev-ca-key.pem k8s-local-dev-ca.key
mv -f k8s-local-dev-ca.pem k8s-local-dev-ca.crt
cp k8s-local-dev-ca.crt ../ansible/roles/k8s_common/files/pki/local-dev
cp k8s-local-dev-ca.key ../ansible/roles/k8s_master/files/pki/local-dev
cp k8s-local-dev-ca.crt ../ansible/roles/k8s_master/files/pki/local-dev


# Generate the Kubernetes etcd intermediate CA private key and certificate
cfssl gencert -initca k8s-local-dev-etcd-ca-csr.json | cfssljson -bare k8s-local-dev-etcd-ca
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile intermediate_ca k8s-local-dev-etcd-ca.csr | cfssljson -bare k8s-local-dev-etcd-ca
mv -f k8s-local-dev-etcd-ca-key.pem k8s-local-dev-etcd-ca.key
mv -f k8s-local-dev-etcd-ca.pem k8s-local-dev-etcd-ca.crt
cp k8s-local-dev-etcd-ca.crt ../ansible/roles/k8s_common/files/pki/local-dev
cp k8s-local-dev-etcd-ca.key ../ansible/roles/k8s_master/files/pki/local-dev
cp k8s-local-dev-etcd-ca.crt ../ansible/roles/k8s_master/files/pki/local-dev


# Generate the etcd cluster private key and certificate
cfssl genkey etcd-local-dev-csr.json | cfssljson -bare etcd-local-dev
cfssl sign -ca=etcd-local-dev-ca.crt -ca-key=etcd-local-dev-ca.key -config=etcd-local-dev-ca-config.json -profile client_server etcd-local-dev.csr | cfssljson -bare etcd-local-dev
mv -f etcd-local-dev-key.pem etcd-local-dev.key
mv -f etcd-local-dev.pem etcd-local-dev.crt
cp etcd-local-dev.key ../ansible/roles/etcd/files/pki/local-dev
cp etcd-local-dev.crt ../ansible/roles/etcd/files/pki/local-dev


# Generate the etcd cluster hosts private keys and certificates
cfssl genkey etcd-local-dev-01-csr.json | cfssljson -bare etcd-local-dev-01
cfssl sign -ca=etcd-local-dev-ca.crt -ca-key=etcd-local-dev-ca.key -config=etcd-local-dev-ca-config.json -profile client_server etcd-local-dev-01.csr | cfssljson -bare etcd-local-dev-01
mv -f etcd-local-dev-01-key.pem etcd-local-dev-01.key
mv -f etcd-local-dev-01.pem etcd-local-dev-01.crt
cp etcd-local-dev-01.key ../ansible/roles/etcd/files/pki/local-dev
cp etcd-local-dev-01.crt ../ansible/roles/etcd/files/pki/local-dev

cfssl genkey etcd-local-dev-02-csr.json | cfssljson -bare etcd-local-dev-02
cfssl sign -ca=etcd-local-dev-ca.crt -ca-key=etcd-local-dev-ca.key -config=etcd-local-dev-ca-config.json -profile client_server etcd-local-dev-02.csr | cfssljson -bare etcd-local-dev-02
mv -f etcd-local-dev-02-key.pem etcd-local-dev-02.key
mv -f etcd-local-dev-02.pem etcd-local-dev-02.crt
cp etcd-local-dev-02.key ../ansible/roles/etcd/files/pki/local-dev
cp etcd-local-dev-02.crt ../ansible/roles/etcd/files/pki/local-dev

cfssl genkey etcd-local-dev-03-csr.json | cfssljson -bare etcd-local-dev-03
cfssl sign -ca=etcd-local-dev-ca.crt -ca-key=etcd-local-dev-ca.key -config=etcd-local-dev-ca-config.json -profile client_server etcd-local-dev-03.csr | cfssljson -bare etcd-local-dev-03
mv -f etcd-local-dev-03-key.pem etcd-local-dev-03.key
mv -f etcd-local-dev-03.pem etcd-local-dev-03.crt
cp etcd-local-dev-03.key ../ansible/roles/etcd/files/pki/local-dev
cp etcd-local-dev-03.crt ../ansible/roles/etcd/files/pki/local-dev


# Generate the etcd client key and certificate
cfssl genkey etcd-local-dev-client-csr.json | cfssljson -bare etcd-local-dev-client
cfssl sign -ca=etcd-local-dev-ca.crt -ca-key=etcd-local-dev-ca.key -config=etcd-local-dev-ca-config.json -profile client_server etcd-local-dev-client.csr | cfssljson -bare etcd-local-dev-client
mv -f etcd-local-dev-client-key.pem etcd-local-dev-client.key
mv -f etcd-local-dev-client.pem etcd-local-dev-client.crt
cp etcd-local-dev-client.key ../ansible/roles/etcd/files/pki/local-dev
cp etcd-local-dev-client.crt ../ansible/roles/etcd/files/pki/local-dev


# Generate the Kubernetes etcd client private keys and certificates for connecting a Kubernetes cluster to an external etcd cluster
cfssl genkey k8s-local-dev-m-01-csr.json | cfssljson -bare k8s-local-dev-m-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-dev-m-01.csr | cfssljson -bare k8s-local-dev-m-01
mv -f k8s-local-dev-m-01-key.pem k8s-local-dev-m-01.key
mv -f k8s-local-dev-m-01.pem k8s-local-dev-m-01.crt
cp k8s-local-dev-m-01.key ../ansible/roles/k8s_master/files/pki/local-dev
cp k8s-local-dev-m-01.crt ../ansible/roles/k8s_master/files/pki/local-dev

cfssl genkey k8s-local-dev-m-02-csr.json | cfssljson -bare k8s-local-dev-m-02
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-dev-m-02.csr | cfssljson -bare k8s-local-dev-m-02
mv -f k8s-local-dev-m-02-key.pem k8s-local-dev-m-02.key
mv -f k8s-local-dev-m-02.pem k8s-local-dev-m-02.crt
cp k8s-local-dev-m-02.key ../ansible/roles/k8s_master/files/pki/local-dev
cp k8s-local-dev-m-02.crt ../ansible/roles/k8s_master/files/pki/local-dev

cfssl genkey k8s-local-dev-m-03-csr.json | cfssljson -bare k8s-local-dev-m-03
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-dev-m-03.csr | cfssljson -bare k8s-local-dev-m-03
mv -f k8s-local-dev-m-03-key.pem k8s-local-dev-m-03.key
mv -f k8s-local-dev-m-03.pem k8s-local-dev-m-03.crt
cp k8s-local-dev-m-03.key ../ansible/roles/k8s_master/files/pki/local-dev
cp k8s-local-dev-m-03.crt ../ansible/roles/k8s_master/files/pki/local-dev


# Generate the Istio intermediate CA private key and certificate
cfssl gencert -initca k8s-local-dev-istio-ca-csr.json | cfssljson -bare k8s-local-dev-istio-ca
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile intermediate_ca k8s-local-dev-istio-ca.csr | cfssljson -bare k8s-local-dev-istio-ca
mv -f k8s-local-dev-istio-ca-key.pem k8s-local-dev-istio-ca.key
mv -f k8s-local-dev-istio-ca.pem k8s-local-dev-istio-ca.crt
cat k8s-local-dev-istio-ca.crt > k8s-local-dev-istio-ca-chain.crt
cat ca.crt >> k8s-local-dev-istio-ca-chain.crt
cp k8s-local-dev-istio-ca.key ../ansible/roles/k8s_istio/files/pki/local-dev
cp k8s-local-dev-istio-ca.crt ../ansible/roles/k8s_istio/files/pki/local-dev
cp k8s-local-dev-istio-ca-chain.crt ../ansible/roles/k8s_istio/files/pki/local-dev


# Generate the Istio ingress gateway private key and certificate
cfssl genkey k8s-local-dev-istio-ingressgateway-csr.json | cfssljson -bare k8s-local-dev-istio-ingressgateway
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-dev-istio-ingressgateway.csr | cfssljson -bare k8s-local-dev-istio-ingressgateway
mv -f k8s-local-dev-istio-ingressgateway-key.pem k8s-local-dev-istio-ingressgateway.key
mv -f k8s-local-dev-istio-ingressgateway.pem k8s-local-dev-istio-ingressgateway.crt
cp k8s-local-dev-istio-ingressgateway.key ../ansible/roles/k8s_istio/files/pki/local-dev
cp k8s-local-dev-istio-ingressgateway.crt ../ansible/roles/k8s_istio/files/pki/local-dev


# Generate the default ingress gateway private key and certificate
cfssl genkey k8s-local-dev-default-ingressgateway-csr.json | cfssljson -bare k8s-local-dev-default-ingressgateway
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-dev-default-ingressgateway.csr | cfssljson -bare k8s-local-dev-default-ingressgateway
mv -f k8s-local-dev-default-ingressgateway-key.pem k8s-local-dev-default-ingressgateway.key
mv -f k8s-local-dev-default-ingressgateway.pem k8s-local-dev-default-ingressgateway.crt
cp k8s-local-dev-default-ingressgateway.key ../ansible/roles/k8s_istio/files/pki/local-dev
cp k8s-local-dev-default-ingressgateway.crt ../ansible/roles/k8s_istio/files/pki/local-dev


# Generate the TopoLVM mutating webhook private key and certificate
cfssl genkey k8s-local-dev-topolvm-mutatingwebhook-csr.json | cfssljson -bare k8s-local-dev-topolvm-mutatingwebhook
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-dev-topolvm-mutatingwebhook.csr | cfssljson -bare k8s-local-dev-topolvm-mutatingwebhook
mv -f k8s-local-dev-topolvm-mutatingwebhook-key.pem k8s-local-dev-topolvm-mutatingwebhook.key
mv -f k8s-local-dev-topolvm-mutatingwebhook.pem k8s-local-dev-topolvm-mutatingwebhook.crt
cp k8s-local-dev-topolvm-mutatingwebhook.key ../ansible/roles/k8s_storage/files/pki/local-dev
cp k8s-local-dev-topolvm-mutatingwebhook.crt ../ansible/roles/k8s_storage/files/pki/local-dev


# Generate the Elasticsearch private key and certificate
cfssl genkey k8s-local-dev-elasticsearch-csr.json | cfssljson -bare k8s-local-dev-elasticsearch
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-dev-elasticsearch.csr | cfssljson -bare k8s-local-dev-elasticsearch
mv -f k8s-local-dev-elasticsearch-key.pem k8s-local-dev-elasticsearch.key
mv -f k8s-local-dev-elasticsearch.pem k8s-local-dev-elasticsearch.crt
cp k8s-local-dev-elasticsearch.key ../ansible/roles/k8s_monitoring/files/pki/local-dev
cp k8s-local-dev-elasticsearch.crt ../ansible/roles/k8s_monitoring/files/pki/local-dev


# Generate the Kibana private key and certificate
cfssl genkey k8s-local-dev-kibana-csr.json | cfssljson -bare k8s-local-dev-kibana
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-dev-kibana.csr | cfssljson -bare k8s-local-dev-kibana
mv -f k8s-local-dev-kibana-key.pem k8s-local-dev-kibana.key
mv -f k8s-local-dev-kibana.pem k8s-local-dev-kibana.crt
cp k8s-local-dev-kibana.key ../ansible/roles/k8s_monitoring/files/pki/local-dev
cp k8s-local-dev-kibana.crt ../ansible/roles/k8s_monitoring/files/pki/local-dev


# Generate the Jaeger private key and certificate
cfssl genkey k8s-local-dev-jaeger-csr.json | cfssljson -bare k8s-local-dev-jaeger
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-dev-jaeger.csr | cfssljson -bare k8s-local-dev-jaeger
mv -f k8s-local-dev-jaeger-key.pem k8s-local-dev-jaeger.key
mv -f k8s-local-dev-jaeger.pem k8s-local-dev-jaeger.crt
cp k8s-local-dev-jaeger.key ../ansible/roles/k8s_monitoring/files/pki/local-dev
cp k8s-local-dev-jaeger.crt ../ansible/roles/k8s_monitoring/files/pki/local-dev


# Generate the Kafka hosts private keys and certificates
cfssl genkey kafka-local-dev-01-csr.json | cfssljson -bare kafka-local-dev-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-local-dev-01.csr | cfssljson -bare kafka-local-dev-01
mv -f kafka-local-dev-01-key.pem kafka-local-dev-01.key
mv -f kafka-local-dev-01.pem kafka-local-dev-01.crt
cp kafka-local-dev-01.key ../ansible/roles/kafka_zookeeper/files/pki/local-dev
cp kafka-local-dev-01.crt ../ansible/roles/kafka_zookeeper/files/pki/local-dev

cfssl genkey kafka-local-dev-02-csr.json | cfssljson -bare kafka-local-dev-02
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-local-dev-02.csr | cfssljson -bare kafka-local-dev-02
mv -f kafka-local-dev-02-key.pem kafka-local-dev-02.key
mv -f kafka-local-dev-02.pem kafka-local-dev-02.crt
cp kafka-local-dev-02.key ../ansible/roles/kafka_zookeeper/files/pki/local-dev
cp kafka-local-dev-02.crt ../ansible/roles/kafka_zookeeper/files/pki/local-dev

cfssl genkey kafka-local-dev-03-csr.json | cfssljson -bare kafka-local-dev-03
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-local-dev-03.csr | cfssljson -bare kafka-local-dev-03
mv -f kafka-local-dev-03-key.pem kafka-local-dev-03.key
mv -f kafka-local-dev-03.pem kafka-local-dev-03.crt
cp kafka-local-dev-03.key ../ansible/roles/kafka_zookeeper/files/pki/local-dev
cp kafka-local-dev-03.crt ../ansible/roles/kafka_zookeeper/files/pki/local-dev

cfssl genkey kafka-local-dev-04-csr.json | cfssljson -bare kafka-local-dev-04
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-local-dev-04.csr | cfssljson -bare kafka-local-dev-04
mv -f kafka-local-dev-04-key.pem kafka-local-dev-04.key
mv -f kafka-local-dev-04.pem kafka-local-dev-04.crt
cp kafka-local-dev-04.key ../ansible/roles/kafka_zookeeper/files/pki/local-dev
cp kafka-local-dev-04.crt ../ansible/roles/kafka_zookeeper/files/pki/local-dev

cfssl genkey kafka-local-dev-05-csr.json | cfssljson -bare kafka-local-dev-05
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-local-dev-05.csr | cfssljson -bare kafka-local-dev-05
mv -f kafka-local-dev-05-key.pem kafka-local-dev-05.key
mv -f kafka-local-dev-05.pem kafka-local-dev-05.crt
cp kafka-local-dev-05.key ../ansible/roles/kafka_zookeeper/files/pki/local-dev
cp kafka-local-dev-05.crt ../ansible/roles/kafka_zookeeper/files/pki/local-dev

cfssl genkey kafka-local-dev-06-csr.json | cfssljson -bare kafka-local-dev-06
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-local-dev-06.csr | cfssljson -bare kafka-local-dev-06
mv -f kafka-local-dev-06-key.pem kafka-local-dev-06.key
mv -f kafka-local-dev-06.pem kafka-local-dev-06.crt
cp kafka-local-dev-06.key ../ansible/roles/kafka_zookeeper/files/pki/local-dev
cp kafka-local-dev-06.crt ../ansible/roles/kafka_zookeeper/files/pki/local-dev


# Generate the Kafka Server certificate
cfssl genkey kafka-local-dev-server-csr.json | cfssljson -bare kafka-local-dev-server
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-local-dev-server.csr | cfssljson -bare kafka-local-dev-server
mv -f kafka-local-dev-server-key.pem kafka-local-dev-server.key
mv -f kafka-local-dev-server.pem kafka-local-dev-server.crt
cp kafka-local-dev-server.key ../ansible/roles/kafka_server/files/pki/local-dev
cp kafka-local-dev-server.crt ../ansible/roles/kafka_server/files/pki/local-dev


# Generate the Kafka MirrorMaker certificate
cfssl genkey kafka-local-dev-mirrormaker-csr.json | cfssljson -bare kafka-local-dev-mirrormaker
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client kafka-local-dev-mirrormaker.csr | cfssljson -bare kafka-local-dev-mirrormaker
mv -f kafka-local-dev-mirrormaker-key.pem kafka-local-dev-mirrormaker.key
mv -f kafka-local-dev-mirrormaker.pem kafka-local-dev-mirrormaker.crt
cp kafka-local-dev-mirrormaker.key ../ansible/roles/kafka_mirrormaker/files/pki/local-dev
cp kafka-local-dev-mirrormaker.crt ../ansible/roles/kafka_mirrormaker/files/pki/local-dev


# Generate the Kafka Admin certificate
cfssl genkey kafka-local-dev-admin-csr.json | cfssljson -bare kafka-local-dev-admin
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client kafka-local-dev-admin.csr | cfssljson -bare kafka-local-dev-admin
mv -f kafka-local-dev-admin-key.pem kafka-local-dev-admin.key
mv -f kafka-local-dev-admin.pem kafka-local-dev-admin.crt
cp kafka-local-dev-admin.key ../ansible/roles/kafka_server/files/pki/local-dev
cp kafka-local-dev-admin.crt ../ansible/roles/kafka_server/files/pki/local-dev


# Generate the Kafka demo-producer certificate
cfssl genkey demo-producer-csr.json | cfssljson -bare demo-producer
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client demo-producer.csr | cfssljson -bare demo-producer
mv -f demo-producer-key.pem demo-producer.key
mv -f demo-producer.pem demo-producer.crt
rm -f demo-producer.p12
openssl pkcs12 -export -name "demo-producer" -out demo-producer.p12 -inkey demo-producer.key -in demo-producer.crt -CAfile ca.crt -caname "Local Root Certificate Authority (1)" -chain -passout pass:bdm1QKInU586etBN
openssl pkcs12 -info -nodes -in demo-producer.p12 -passin pass:bdm1QKInU586etBN
cp demo-producer.p12 ../demos/kafka/demo-producer/pki/demo-producer.p12


# Generate the Kafka demo-consumer certificate
cfssl genkey demo-consumer-csr.json | cfssljson -bare demo-consumer
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client demo-consumer.csr | cfssljson -bare demo-consumer
mv -f demo-consumer-key.pem demo-consumer.key
mv -f demo-consumer.pem demo-consumer.crt
rm -f demo-consumer.p12
openssl pkcs12 -export -name "demo-consumer" -out demo-consumer.p12 -inkey demo-consumer.key -in demo-consumer.crt -CAfile ca.crt -caname "Local Root Certificate Authority (1)" -chain -passout pass:C0OlV5W19wyvboZv
openssl pkcs12 -info -nodes -in demo-consumer.p12 -passin pass:C0OlV5W19wyvboZv
cp demo-consumer.p12 ../demos/kafka/demo-consumer/pki/demo-consumer.p12

