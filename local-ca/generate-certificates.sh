#!/bin/sh

# Execute the following command to allow the script to be executed on MacOS:
#   xattr -d com.apple.quarantine generate-certificates.sh

# NOTE: All certificates follow one of the following naming conventions:
#
#         1. <platform>-<platform_instance_name_or_cluster_name>
#
#              e.g. etcd-local
#
#         2. <platform>-<platform_instance_name_or_cluster_name>-<platform_component>
#
#              e.g. k8s-local-topolvm-mutatingwebhook where the <platform> is k8s, the
#                   <platform_instance_name_or_cluster_name> is local, and the
#                   <platform_component> is topolvm-mutatingwebhook
#
#                   k8s-local-kibana where the <platform> is k8s, the
#                   <platform_instance_name_or_cluster_name> is local, and the
#                   <platform_component> is kibana
#
#                   k8s-digital-prod-elasticsearch where the <platform> is k8s, the
#                   <platform_instance_name_or_cluster_name> is digital-prod, and the
#                   <platform_component> is elasticsearch
#
#         3. <hostname>, where <hostname> is normally made up of
#            <platform>-<platform_instance_name_or_cluster_name>-<instance_id>
#
#              e.g. kafka-local-01 where the <instance_id> is 01
#
#         4. <hostname>-<purpose>, where <hostname> is normally made up of
#            <platform>-<platform_instance_name_or_cluster_name>-<instance_id>
#
#              e.g. etcd-local-01-etcd-peer where the <purpose> is etcd-peer

mkdir -p ../ansible/roles/etcd/files/pki/local
mkdir -p ../ansible/roles/k8s_common/files/pki/local
mkdir -p ../ansible/roles/k8s_istio/files/pki/local
mkdir -p ../ansible/roles/k8s_master/files/pki/local
mkdir -p ../ansible/roles/k8s_monitoring/files/pki/local
mkdir -p ../ansible/roles/k8s_operators/files/pki/local
mkdir -p ../ansible/roles/k8s_storage/files/pki/local
mkdir -p ../ansible/roles/kafka_server/files/pki/local
mkdir -p ../ansible/roles/kafka_zookeeper/files/pki/local


# Generate the Root CA private key and certificate
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
mv -f ca.pem ca.crt
mv -f ca-key.pem ca.key
rm -f ca.p12
keytool -importcert -noprompt -trustcacerts -alias "Local Root Certificate Authority (1)" -file ca.crt -keystore ca.p12 -storetype PKCS12 -storepass "ulLdVI9hUP46gaQj"
cp ca.crt ../ansible/roles/etcd/files/pki/local
cp ca.crt ../ansible/roles/k8s_common/files/pki/local/ca.crt
cp ca.crt ../ansible/roles/k8s_istio/files/pki/local/ca.crt
cp ca.crt ../ansible/roles/k8s_master/files/pki/local/ca.crt
cp ca.crt ../ansible/roles/k8s_master/files/pki/local/etcd-ca.crt
cp ca.crt ../ansible/roles/k8s_monitoring/files/pki/local/ca.crt
cp ca.crt ../ansible/roles/k8s_operators/files/pki/local/ca.crt
cp ca.crt ../ansible/roles/k8s_storage/files/pki/local/ca.crt
cp ca.crt ../ansible/roles/k8s_storage/files/pki/local/ca-bundle.crt
cp ca.crt ../ansible/roles/kafka_server/files/pki/local/ca.crt
cp ca.crt ../ansible/roles/kafka_zookeeper/files/pki/local/ca.crt
cp ca.p12 ../demos/kafka/demo-producer/src/main/resources/ca.p12
cp ca.p12 ../demos/kafka/demo-consumer/src/main/resources/ca.p12


# Generate the etcd intermediate CA private key and certificate
cfssl gencert -initca etcd-local-ca-csr.json | cfssljson -bare etcd-local-ca
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile intermediate_ca etcd-local-ca.csr | cfssljson -bare etcd-local-ca
mv -f etcd-local-ca-key.pem etcd-local-ca.key
mv -f etcd-local-ca.pem etcd-local-ca.crt
cp etcd-local-ca.crt ../ansible/roles/etcd/files/pki/local
cp etcd-local-ca.key ../ansible/roles/etcd/files/pki/local


# Generate the Kubernetes intermediate CA private key and certificate
cfssl gencert -initca k8s-local-ca-csr.json | cfssljson -bare k8s-local-ca
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile intermediate_ca k8s-local-ca.csr | cfssljson -bare k8s-local-ca
mv -f k8s-local-ca-key.pem k8s-local-ca.key
mv -f k8s-local-ca.pem k8s-local-ca.crt
cp k8s-local-ca.crt ../ansible/roles/k8s_common/files/pki/local
cp k8s-local-ca.key ../ansible/roles/k8s_master/files/pki/local
cp k8s-local-ca.crt ../ansible/roles/k8s_master/files/pki/local


# Generate the Kubernetes etcd intermediate CA private key and certificate
cfssl gencert -initca k8s-local-etcd-ca-csr.json | cfssljson -bare k8s-local-etcd-ca
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile intermediate_ca k8s-local-etcd-ca.csr | cfssljson -bare k8s-local-etcd-ca
mv -f k8s-local-etcd-ca-key.pem k8s-local-etcd-ca.key
mv -f k8s-local-etcd-ca.pem k8s-local-etcd-ca.crt
cp k8s-local-etcd-ca.crt ../ansible/roles/k8s_common/files/pki/local
cp k8s-local-etcd-ca.key ../ansible/roles/k8s_master/files/pki/local
cp k8s-local-etcd-ca.crt ../ansible/roles/k8s_master/files/pki/local


# Generate the etcd cluster private key and certificate
cfssl genkey etcd-local-csr.json | cfssljson -bare etcd-local
cfssl sign -ca=etcd-local-ca.crt -ca-key=etcd-local-ca.key -config=etcd-local-ca-config.json -profile client_server etcd-local.csr | cfssljson -bare etcd-local
mv -f etcd-local-key.pem etcd-local.key
mv -f etcd-local.pem etcd-local.crt
cp etcd-local.key ../ansible/roles/etcd/files/pki/local
cp etcd-local.crt ../ansible/roles/etcd/files/pki/local


# Generate the etcd cluster peer private keys and certificates
cfssl genkey etcd-local-01-etcd-peer-csr.json | cfssljson -bare etcd-local-01-etcd-peer
cfssl sign -ca=etcd-local-ca.crt -ca-key=etcd-local-ca.key -config=etcd-local-ca-config.json -profile client_server etcd-local-01-etcd-peer.csr | cfssljson -bare etcd-local-01-etcd-peer
mv -f etcd-local-01-etcd-peer-key.pem etcd-local-01-etcd-peer.key
mv -f etcd-local-01-etcd-peer.pem etcd-local-01-etcd-peer.crt
cp etcd-local-01-etcd-peer.key ../ansible/roles/etcd/files/pki/local
cp etcd-local-01-etcd-peer.crt ../ansible/roles/etcd/files/pki/local

cfssl genkey etcd-local-02-etcd-peer-csr.json | cfssljson -bare etcd-local-02-etcd-peer
cfssl sign -ca=etcd-local-ca.crt -ca-key=etcd-local-ca.key -config=etcd-local-ca-config.json -profile client_server etcd-local-02-etcd-peer.csr | cfssljson -bare etcd-local-02-etcd-peer
mv -f etcd-local-02-etcd-peer-key.pem etcd-local-02-etcd-peer.key
mv -f etcd-local-02-etcd-peer.pem etcd-local-02-etcd-peer.crt
cp etcd-local-02-etcd-peer.key ../ansible/roles/etcd/files/pki/local
cp etcd-local-02-etcd-peer.crt ../ansible/roles/etcd/files/pki/local

cfssl genkey etcd-local-03-etcd-peer-csr.json | cfssljson -bare etcd-local-03-etcd-peer
cfssl sign -ca=etcd-local-ca.crt -ca-key=etcd-local-ca.key -config=etcd-local-ca-config.json -profile client_server etcd-local-03-etcd-peer.csr | cfssljson -bare etcd-local-03-etcd-peer
mv -f etcd-local-03-etcd-peer-key.pem etcd-local-03-etcd-peer.key
mv -f etcd-local-03-etcd-peer.pem etcd-local-03-etcd-peer.crt
cp etcd-local-03-etcd-peer.key ../ansible/roles/etcd/files/pki/local
cp etcd-local-03-etcd-peer.crt ../ansible/roles/etcd/files/pki/local


# Generate the etcd client key and certificate
cfssl genkey etcd-local-client-csr.json | cfssljson -bare etcd-local-client
cfssl sign -ca=etcd-local-ca.crt -ca-key=etcd-local-ca.key -config=etcd-local-ca-config.json -profile client_server etcd-local-client.csr | cfssljson -bare etcd-local-client
mv -f etcd-local-client-key.pem etcd-local-client.key
mv -f etcd-local-client.pem etcd-local-client.crt
cp etcd-local-client.key ../ansible/roles/etcd/files/pki/local
cp etcd-local-client.crt ../ansible/roles/etcd/files/pki/local


# Generate the Kubernetes etcd client private keys and certificates for connecting a Kubernetes cluster to an external etcd cluster
cfssl genkey k8s-local-m-01-etcd-client-csr.json | cfssljson -bare k8s-local-m-01-etcd-client
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-m-01-etcd-client.csr | cfssljson -bare k8s-local-m-01-etcd-client
mv -f k8s-local-m-01-etcd-client-key.pem k8s-local-m-01-etcd-client.key
mv -f k8s-local-m-01-etcd-client.pem k8s-local-m-01-etcd-client.crt
cp k8s-local-m-01-etcd-client.key ../ansible/roles/k8s_master/files/pki/local
cp k8s-local-m-01-etcd-client.crt ../ansible/roles/k8s_master/files/pki/local

cfssl genkey k8s-local-m-02-etcd-client-csr.json | cfssljson -bare k8s-local-m-02-etcd-client
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-m-02-etcd-client.csr | cfssljson -bare k8s-local-m-02-etcd-client
mv -f k8s-local-m-02-etcd-client-key.pem k8s-local-m-02-etcd-client.key
mv -f k8s-local-m-02-etcd-client.pem k8s-local-m-02-etcd-client.crt
cp k8s-local-m-02-etcd-client.key ../ansible/roles/k8s_master/files/pki/local
cp k8s-local-m-02-etcd-client.crt ../ansible/roles/k8s_master/files/pki/local

cfssl genkey k8s-local-m-03-etcd-client-csr.json | cfssljson -bare k8s-local-m-03-etcd-client
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-m-03-etcd-client.csr | cfssljson -bare k8s-local-m-03-etcd-client
mv -f k8s-local-m-03-etcd-client-key.pem k8s-local-m-03-etcd-client.key
mv -f k8s-local-m-03-etcd-client.pem k8s-local-m-03-etcd-client.crt
cp k8s-local-m-03-etcd-client.key ../ansible/roles/k8s_master/files/pki/local
cp k8s-local-m-03-etcd-client.crt ../ansible/roles/k8s_master/files/pki/local


# Generate the Istio intermediate CA private key and certificate
cfssl gencert -initca k8s-local-istio-ca-csr.json | cfssljson -bare k8s-local-istio-ca
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile intermediate_ca k8s-local-istio-ca.csr | cfssljson -bare k8s-local-istio-ca
mv -f k8s-local-istio-ca-key.pem k8s-local-istio-ca.key
mv -f k8s-local-istio-ca.pem k8s-local-istio-ca.crt
cat k8s-local-istio-ca.crt > k8s-local-istio-ca-chain.crt
cat ca.crt >> k8s-local-istio-ca-chain.crt
cp k8s-local-istio-ca.key ../ansible/roles/k8s_istio/files/pki/local
cp k8s-local-istio-ca.crt ../ansible/roles/k8s_istio/files/pki/local
cp k8s-local-istio-ca-chain.crt ../ansible/roles/k8s_istio/files/pki/local


# Generate the Istio ingress gateway private key and certificate
cfssl genkey k8s-local-istio-ingressgateway-csr.json | cfssljson -bare k8s-local-istio-ingressgateway
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-istio-ingressgateway.csr | cfssljson -bare k8s-local-istio-ingressgateway
mv -f k8s-local-istio-ingressgateway-key.pem k8s-local-istio-ingressgateway.key
mv -f k8s-local-istio-ingressgateway.pem k8s-local-istio-ingressgateway.crt
cp k8s-local-istio-ingressgateway.key ../ansible/roles/k8s_istio/files/pki/local
cp k8s-local-istio-ingressgateway.crt ../ansible/roles/k8s_istio/files/pki/local


# Generate the default ingress gateway private key and certificate
cfssl genkey k8s-local-default-ingressgateway-csr.json | cfssljson -bare k8s-local-default-ingressgateway
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-default-ingressgateway.csr | cfssljson -bare k8s-local-default-ingressgateway
mv -f k8s-local-default-ingressgateway-key.pem k8s-local-default-ingressgateway.key
mv -f k8s-local-default-ingressgateway.pem k8s-local-default-ingressgateway.crt
cp k8s-local-default-ingressgateway.key ../ansible/roles/k8s_istio/files/pki/local
cp k8s-local-default-ingressgateway.crt ../ansible/roles/k8s_istio/files/pki/local


# Generate the TopoLVM mutating webhook private key and certificate
cfssl genkey k8s-local-topolvm-mutatingwebhook-csr.json | cfssljson -bare k8s-local-topolvm-mutatingwebhook
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-topolvm-mutatingwebhook.csr | cfssljson -bare k8s-local-topolvm-mutatingwebhook
mv -f k8s-local-topolvm-mutatingwebhook-key.pem k8s-local-topolvm-mutatingwebhook.key
mv -f k8s-local-topolvm-mutatingwebhook.pem k8s-local-topolvm-mutatingwebhook.crt
cp k8s-local-topolvm-mutatingwebhook.key ../ansible/roles/k8s_storage/files/pki/local
cp k8s-local-topolvm-mutatingwebhook.crt ../ansible/roles/k8s_storage/files/pki/local


# Generate the Elasticsearch private key and certificate
cfssl genkey k8s-local-elasticsearch-csr.json | cfssljson -bare k8s-local-elasticsearch
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-elasticsearch.csr | cfssljson -bare k8s-local-elasticsearch
mv -f k8s-local-elasticsearch-key.pem k8s-local-elasticsearch.key
mv -f k8s-local-elasticsearch.pem k8s-local-elasticsearch.crt
cp k8s-local-elasticsearch.key ../ansible/roles/k8s_monitoring/files/pki/local
cp k8s-local-elasticsearch.crt ../ansible/roles/k8s_monitoring/files/pki/local


# Generate the Kibana private key and certificate
cfssl genkey k8s-local-kibana-csr.json | cfssljson -bare k8s-local-kibana
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-kibana.csr | cfssljson -bare k8s-local-kibana
mv -f k8s-local-kibana-key.pem k8s-local-kibana.key
mv -f k8s-local-kibana.pem k8s-local-kibana.crt
cp k8s-local-kibana.key ../ansible/roles/k8s_monitoring/files/pki/local
cp k8s-local-kibana.crt ../ansible/roles/k8s_monitoring/files/pki/local


# Generate the Jaeger private key and certificate
cfssl genkey k8s-local-jaeger-csr.json | cfssljson -bare k8s-local-jaeger
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-local-jaeger.csr | cfssljson -bare k8s-local-jaeger
mv -f k8s-local-jaeger-key.pem k8s-local-jaeger.key
mv -f k8s-local-jaeger.pem k8s-local-jaeger.crt
cp k8s-local-jaeger.key ../ansible/roles/k8s_monitoring/files/pki/local
cp k8s-local-jaeger.crt ../ansible/roles/k8s_monitoring/files/pki/local


# Generate the Kafka Zookeeper private keys and certificates
cfssl genkey kafka-local-01-csr.json | cfssljson -bare kafka-local-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-local-01.csr | cfssljson -bare kafka-local-01
mv -f kafka-local-01-key.pem kafka-local-01.key
mv -f kafka-local-01.pem kafka-local-01.crt
cp kafka-local-01.key ../ansible/roles/kafka_zookeeper/files/pki/local
cp kafka-local-01.crt ../ansible/roles/kafka_zookeeper/files/pki/local

cfssl genkey kafka-local-02-csr.json | cfssljson -bare kafka-local-02
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-local-02.csr | cfssljson -bare kafka-local-02
mv -f kafka-local-02-key.pem kafka-local-02.key
mv -f kafka-local-02.pem kafka-local-02.crt
cp kafka-local-02.key ../ansible/roles/kafka_zookeeper/files/pki/local
cp kafka-local-02.crt ../ansible/roles/kafka_zookeeper/files/pki/local

cfssl genkey kafka-local-03-csr.json | cfssljson -bare kafka-local-03
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-local-03.csr | cfssljson -bare kafka-local-03
mv -f kafka-local-03-key.pem kafka-local-03.key
mv -f kafka-local-03.pem kafka-local-03.crt
cp kafka-local-03.key ../ansible/roles/kafka_zookeeper/files/pki/local
cp kafka-local-03.crt ../ansible/roles/kafka_zookeeper/files/pki/local

cfssl genkey kafka-local-04-csr.json | cfssljson -bare kafka-local-04
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-local-04.csr | cfssljson -bare kafka-local-04
mv -f kafka-local-04-key.pem kafka-local-04.key
mv -f kafka-local-04.pem kafka-local-04.crt
cp kafka-local-04.key ../ansible/roles/kafka_zookeeper/files/pki/local
cp kafka-local-04.crt ../ansible/roles/kafka_zookeeper/files/pki/local

cfssl genkey kafka-local-05-csr.json | cfssljson -bare kafka-local-05
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-local-05.csr | cfssljson -bare kafka-local-05
mv -f kafka-local-05-key.pem kafka-local-05.key
mv -f kafka-local-05.pem kafka-local-05.crt
cp kafka-local-05.key ../ansible/roles/kafka_zookeeper/files/pki/local
cp kafka-local-05.crt ../ansible/roles/kafka_zookeeper/files/pki/local

cfssl genkey kafka-local-06-csr.json | cfssljson -bare kafka-local-06
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-local-06.csr | cfssljson -bare kafka-local-06
mv -f kafka-local-06-key.pem kafka-local-06.key
mv -f kafka-local-06.pem kafka-local-06.crt
cp kafka-local-06.key ../ansible/roles/kafka_zookeeper/files/pki/local
cp kafka-local-06.crt ../ansible/roles/kafka_zookeeper/files/pki/local


# Generate the Kafka Server certificate
cfssl genkey kafka-local-server-csr.json | cfssljson -bare kafka-local-server
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-local-server.csr | cfssljson -bare kafka-local-server
mv -f kafka-local-server-key.pem kafka-local-server.key
mv -f kafka-local-server.pem kafka-local-server.crt
cp kafka-local-server.key ../ansible/roles/kafka_server/files/pki/local
cp kafka-local-server.crt ../ansible/roles/kafka_server/files/pki/local


# Generate the Kafka Admin certificate
cfssl genkey kafka-local-admin-csr.json | cfssljson -bare kafka-local-admin
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client kafka-local-admin.csr | cfssljson -bare kafka-local-admin
mv -f kafka-local-admin-key.pem kafka-local-admin.key
mv -f kafka-local-admin.pem kafka-local-admin.crt
cp kafka-local-admin.key ../ansible/roles/kafka_server/files/pki/local
cp kafka-local-admin.crt ../ansible/roles/kafka_server/files/pki/local


# Generate the Kafka demo-producer certificate
cfssl genkey demo-producer-csr.json | cfssljson -bare demo-producer
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client demo-producer.csr | cfssljson -bare demo-producer
mv -f demo-producer-key.pem demo-producer.key
mv -f demo-producer.pem demo-producer.crt
rm -f demo-producer.p12
openssl pkcs12 -export -name "demo-producer" -out demo-producer.p12 -inkey demo-producer.key -in demo-producer.crt -CAfile ca.crt -caname "Local Root Certificate Authority (1)" -chain -passout pass:bdm1QKInU586etBN
openssl pkcs12 -info -nodes -in demo-producer.p12 -passin pass:bdm1QKInU586etBN
cp demo-producer.p12 ../demos/kafka/demo-producer/src/main/resources/demo-producer.p12


# Generate the Kafka demo-consumer certificate
cfssl genkey demo-consumer-csr.json | cfssljson -bare demo-consumer
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client demo-consumer.csr | cfssljson -bare demo-consumer
mv -f demo-consumer-key.pem demo-consumer.key
mv -f demo-consumer.pem demo-consumer.crt
rm -f demo-consumer.p12
openssl pkcs12 -export -name "demo-consumer" -out demo-consumer.p12 -inkey demo-consumer.key -in demo-consumer.crt -CAfile ca.crt -caname "Local Root Certificate Authority (1)" -chain -passout pass:C0OlV5W19wyvboZv
openssl pkcs12 -info -nodes -in demo-consumer.p12 -passin pass:C0OlV5W19wyvboZv
cp demo-consumer.p12 ../demos/kafka/demo-consumer/src/main/resources/demo-consumer.p12

