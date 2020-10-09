#!/bin/sh

# Execute the following command to allow the script to be executed on MacOS:
#   xattr -d com.apple.quarantine generate-certificates.sh

# NOTE: All certificates follow one of the following naming conventions:
#
#         1. <platform>-<platform_instance_name_or_cluster_name>-<environment>
#
#              e.g. etcd-digital-dev
#
#         2. <platform>-<platform_component_or_role>-<platform_instance_name_or_cluster_name>-<environment>
#
#              e.g. k8s-topolvm--mutatingwebhook-digital-dev where the <platform> is k8s,
#                   the <platform_component_or_role> is topolvm-mutatingwebhook, the
#                   <platform_instance_name_or_cluster_name> is digital, and the
#                   <environment> is dev.
#
#                   k8s-kibana-digital-dev where the <platform> is k8s, the
#                   <platform_component_or_role> is kibana, the
#                   <platform_instance_name_or_cluster_name> is digital, and the
#                   <environment> is dev.
#
#
#         3. <hostname>, where <hostname> is normally made up of
#            <platform>-<platform_instance_name_or_cluster_name>-<environment>-<instance_id>
#
#              e.g. kafka-digital-dev-01 where the <platform> is kafka, the
#                   <platform_instance_name_or_cluster_name> is digital, the <environment>
#                   is dev, and the <instance_id> is 01
#
#         4. <hostname>-<purpose>, where <hostname> is normally made up of
#            <platform>-<platform_instance_name_or_cluster_name>-<environment>-<instance_id>
#
#              e.g. etcd-digital-dev-01-etcd-peer where the <platform> is etcd, the
#                   <platform_instance_name_or_cluster_name> is digital, the <environment>
#                   is dev, the <instance_id> is 01, and the <purpose> is etcd-peer


mkdir -p ../ansible/pki/burrow/dev
mkdir -p ../ansible/pki/confluent_kafka_mirrormaker/digital_dev
mkdir -p ../ansible/pki/confluent_kafka_server/digital_dev
mkdir -p ../ansible/pki/confluent_schema_registry/digital_dev
mkdir -p ../ansible/pki/confluent_zookeeper/digital_dev
mkdir -p ../ansible/pki/confluent_kafka_mirrormaker/analytics_dev
mkdir -p ../ansible/pki/confluent_kafka_server/analytics_dev
mkdir -p ../ansible/pki/confluent_schema_registry/analytics_dev
mkdir -p ../ansible/pki/confluent_zookeeper/analytics_dev
mkdir -p ../ansible/pki/etcd/digital_dev
mkdir -p ../ansible/pki/k8s_common/digital_dev
mkdir -p ../ansible/pki/k8s_istio/digital_dev
mkdir -p ../ansible/pki/k8s_master/digital_dev
mkdir -p ../ansible/pki/k8s_monitoring/digital_dev
mkdir -p ../ansible/pki/k8s_operators/digital_dev
mkdir -p ../ansible/pki/k8s_storage/digital_dev
mkdir -p ../ansible/pki/kafka_mirrormaker/digital_dev
mkdir -p ../ansible/pki/kafka_server/digital_dev
mkdir -p ../ansible/pki/kafka_zookeeper/digital_dev
mkdir -p ../ansible/pki/kafka_mirrormaker/analytics_dev
mkdir -p ../ansible/pki/kafka_server/analytics_dev
mkdir -p ../ansible/pki/kafka_zookeeper/analytics_dev


# Generate the Root CA private key and certificate
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
mv -f ca.pem ca.crt
mv -f ca-key.pem ca.key
rm -f ca.p12
keytool -importcert -noprompt -trustcacerts -alias "Local Root Certificate Authority (1)" -file ca.crt -keystore ca.p12 -storetype PKCS12 -storepass ulLdVI9hUP46gaQj
# keytool -list -keystore ca.p12 -storetype PKCS12 -storepass ulLdVI9hUP46gaQj
# openssl pkcs12 -info -in ca.p12 -passin pass:ulLdVI9hUP46gaQj
cp ca.crt ../ansible/pki/burrow/dev/ca.crt
cp ca.crt ../ansible/pki/confluent_kafka_mirrormaker/digital_dev/ca.crt
cp ca.crt ../ansible/pki/confluent_kafka_server/digital_dev/ca.crt
cp ca.crt ../ansible/pki/confluent_schema_registry/digital_dev/ca.crt
cp ca.crt ../ansible/pki/confluent_zookeeper/digital_dev/ca.crt
cp ca.crt ../ansible/pki/confluent_kafka_mirrormaker/analytics_dev/ca.crt
cp ca.crt ../ansible/pki/confluent_kafka_server/analytics_dev/ca.crt
cp ca.crt ../ansible/pki/confluent_schema_registry/analytics_dev/ca.crt
cp ca.crt ../ansible/pki/confluent_zookeeper/analytics_dev/ca.crt
cp ca.crt ../ansible/pki/etcd/digital_dev/ca.crt
cp ca.crt ../ansible/pki/k8s_common/digital_dev/ca.crt
cp ca.crt ../ansible/pki/k8s_istio/digital_dev/ca.crt
cp ca.crt ../ansible/pki/k8s_master/digital_dev/ca.crt
cp ca.crt ../ansible/pki/k8s_master/digital_dev/etcd-ca.crt
cp ca.crt ../ansible/pki/k8s_monitoring/digital_dev/ca.crt
cp ca.crt ../ansible/pki/k8s_operators/digital_dev/ca.crt
cp ca.crt ../ansible/pki/k8s_storage/digital_dev/ca.crt
cp ca.crt ../ansible/pki/k8s_storage/digital_dev/ca-bundle.crt
cp ca.crt ../ansible/pki/kafka_mirrormaker/digital_dev/ca.crt
cp ca.crt ../ansible/pki/kafka_server/digital_dev/ca.crt
cp ca.crt ../ansible/pki/kafka_zookeeper/digital_dev/ca.crt
cp ca.crt ../ansible/pki/kafka_mirrormaker/analytics_dev/ca.crt
cp ca.crt ../ansible/pki/kafka_server/analytics_dev/ca.crt
cp ca.crt ../ansible/pki/kafka_zookeeper/analytics_dev/ca.crt
cp ca.p12 ../demos/kafka/demo-producer/pki/ca.p12
cp ca.p12 ../demos/kafka/demo-consumer/pki/ca.p12


# Generate the Confluent hosts private keys and certificates
cfssl genkey confluent-zkks-digital-dev-01-csr.json | cfssljson -bare confluent-zkks-digital-dev-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-zkks-digital-dev-01.csr | cfssljson -bare confluent-zkks-digital-dev-01
mv -f confluent-zkks-digital-dev-01-key.pem confluent-zkks-digital-dev-01.key
mv -f confluent-zkks-digital-dev-01.pem confluent-zkks-digital-dev-01.crt
cp confluent-zkks-digital-dev-01.key ../ansible/pki/confluent_kafka_server/digital_dev
cp confluent-zkks-digital-dev-01.crt ../ansible/pki/confluent_kafka_server/digital_dev
cp confluent-zkks-digital-dev-01.key ../ansible/pki/confluent_zookeeper/digital_dev
cp confluent-zkks-digital-dev-01.crt ../ansible/pki/confluent_zookeeper/digital_dev

cfssl genkey confluent-zkks-digital-dev-02-csr.json | cfssljson -bare confluent-zkks-digital-dev-02
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-zkks-digital-dev-02.csr | cfssljson -bare confluent-zkks-digital-dev-02
mv -f confluent-zkks-digital-dev-02-key.pem confluent-zkks-digital-dev-02.key
mv -f confluent-zkks-digital-dev-02.pem confluent-zkks-digital-dev-02.crt
cp confluent-zkks-digital-dev-02.key ../ansible/pki/confluent_kafka_server/digital_dev
cp confluent-zkks-digital-dev-02.crt ../ansible/pki/confluent_kafka_server/digital_dev
cp confluent-zkks-digital-dev-02.key ../ansible/pki/confluent_zookeeper/digital_dev
cp confluent-zkks-digital-dev-02.crt ../ansible/pki/confluent_zookeeper/digital_dev

cfssl genkey confluent-zkks-digital-dev-03-csr.json | cfssljson -bare confluent-zkks-digital-dev-03
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-zkks-digital-dev-03.csr | cfssljson -bare confluent-zkks-digital-dev-03
mv -f confluent-zkks-digital-dev-03-key.pem confluent-zkks-digital-dev-03.key
mv -f confluent-zkks-digital-dev-03.pem confluent-zkks-digital-dev-03.crt
cp confluent-zkks-digital-dev-03.key ../ansible/pki/confluent_kafka_server/digital_dev
cp confluent-zkks-digital-dev-03.crt ../ansible/pki/confluent_kafka_server/digital_dev
cp confluent-zkks-digital-dev-03.key ../ansible/pki/confluent_zookeeper/digital_dev
cp confluent-zkks-digital-dev-03.crt ../ansible/pki/confluent_zookeeper/digital_dev

cfssl genkey confluent-sr-digital-dev-01-csr.json | cfssljson -bare confluent-sr-digital-dev-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-sr-digital-dev-01.csr | cfssljson -bare confluent-sr-digital-dev-01
mv -f confluent-sr-digital-dev-01-key.pem confluent-sr-digital-dev-01.key
mv -f confluent-sr-digital-dev-01.pem confluent-sr-digital-dev-01.crt
cp confluent-sr-digital-dev-01.key ../ansible/pki/confluent_schema_registry/digital_dev
cp confluent-sr-digital-dev-01.crt ../ansible/pki/confluent_schema_registry/digital_dev

cfssl genkey confluent-mm-digital-dev-01-csr.json | cfssljson -bare confluent-mm-digital-dev-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-mm-digital-dev-01.csr | cfssljson -bare confluent-mm-digital-dev-01
mv -f confluent-mm-digital-dev-01-key.pem confluent-mm-digital-dev-01.key
mv -f confluent-mm-digital-dev-01.pem confluent-mm-digital-dev-01.crt
cp confluent-mm-digital-dev-01.key ../ansible/pki/confluent_kafka_mirrormaker/digital_dev
cp confluent-mm-digital-dev-01.crt ../ansible/pki/confluent_kafka_mirrormaker/digital_dev

cfssl genkey confluent-zkks-analytics-dev-01-csr.json | cfssljson -bare confluent-zkks-analytics-dev-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-zkks-analytics-dev-01.csr | cfssljson -bare confluent-zkks-analytics-dev-01
mv -f confluent-zkks-analytics-dev-01-key.pem confluent-zkks-analytics-dev-01.key
mv -f confluent-zkks-analytics-dev-01.pem confluent-zkks-analytics-dev-01.crt
cp confluent-zkks-analytics-dev-01.key ../ansible/pki/confluent_kafka_server/analytics_dev
cp confluent-zkks-analytics-dev-01.crt ../ansible/pki/confluent_kafka_server/analytics_dev
cp confluent-zkks-analytics-dev-01.key ../ansible/pki/confluent_zookeeper/analytics_dev
cp confluent-zkks-analytics-dev-01.crt ../ansible/pki/confluent_zookeeper/analytics_dev

cfssl genkey confluent-zkks-analytics-dev-02-csr.json | cfssljson -bare confluent-zkks-analytics-dev-02
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-zkks-analytics-dev-02.csr | cfssljson -bare confluent-zkks-analytics-dev-02
mv -f confluent-zkks-analytics-dev-02-key.pem confluent-zkks-analytics-dev-02.key
mv -f confluent-zkks-analytics-dev-02.pem confluent-zkks-analytics-dev-02.crt
cp confluent-zkks-analytics-dev-02.key ../ansible/pki/confluent_kafka_server/analytics_dev
cp confluent-zkks-analytics-dev-02.crt ../ansible/pki/confluent_kafka_server/analytics_dev
cp confluent-zkks-analytics-dev-02.key ../ansible/pki/confluent_zookeeper/analytics_dev
cp confluent-zkks-analytics-dev-02.crt ../ansible/pki/confluent_zookeeper/analytics_dev

cfssl genkey confluent-zkks-analytics-dev-03-csr.json | cfssljson -bare confluent-zkks-analytics-dev-03
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-zkks-analytics-dev-03.csr | cfssljson -bare confluent-zkks-analytics-dev-03
mv -f confluent-zkks-analytics-dev-03-key.pem confluent-zkks-analytics-dev-03.key
mv -f confluent-zkks-analytics-dev-03.pem confluent-zkks-analytics-dev-03.crt
cp confluent-zkks-analytics-dev-03.key ../ansible/pki/confluent_kafka_server/analytics_dev
cp confluent-zkks-analytics-dev-03.crt ../ansible/pki/confluent_kafka_server/analytics_dev
cp confluent-zkks-analytics-dev-03.key ../ansible/pki/confluent_zookeeper/analytics_dev
cp confluent-zkks-analytics-dev-03.crt ../ansible/pki/confluent_zookeeper/analytics_dev

cfssl genkey confluent-sr-analytics-dev-01-csr.json | cfssljson -bare confluent-sr-analytics-dev-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-sr-analytics-dev-01.csr | cfssljson -bare confluent-sr-analytics-dev-01
mv -f confluent-sr-analytics-dev-01-key.pem confluent-sr-analytics-dev-01.key
mv -f confluent-sr-analytics-dev-01.pem confluent-sr-analytics-dev-01.crt
cp confluent-sr-analytics-dev-01.key ../ansible/pki/confluent_schema_registry/analytics_dev
cp confluent-sr-analytics-dev-01.crt ../ansible/pki/confluent_schema_registry/analytics_dev

cfssl genkey confluent-mm-analytics-dev-01-csr.json | cfssljson -bare confluent-mm-analytics-dev-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-mm-analytics-dev-01.csr | cfssljson -bare confluent-mm-analytics-dev-01
mv -f confluent-mm-analytics-dev-01-key.pem confluent-mm-analytics-dev-01.key
mv -f confluent-mm-analytics-dev-01.pem confluent-mm-analytics-dev-01.crt
cp confluent-mm-analytics-dev-01.key ../ansible/pki/confluent_kafka_mirrormaker/analytics_dev
cp confluent-mm-analytics-dev-01.crt ../ansible/pki/confluent_kafka_mirrormaker/analytics_dev


# Generate the Confluent Kafka Admin certificates
cfssl genkey confluent-admin-digital-dev-csr.json | cfssljson -bare confluent-admin-digital-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client confluent-admin-digital-dev.csr | cfssljson -bare confluent-admin-digital-dev
mv -f confluent-admin-digital-dev-key.pem confluent-admin-digital-dev.key
mv -f confluent-admin-digital-dev.pem confluent-admin-digital-dev.crt
cp confluent-admin-digital-dev.key ../ansible/pki/confluent_kafka_server/digital_dev
cp confluent-admin-digital-dev.crt ../ansible/pki/confluent_kafka_server/digital_dev

cfssl genkey confluent-admin-analytics-dev-csr.json | cfssljson -bare confluent-admin-analytics-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client confluent-admin-analytics-dev.csr | cfssljson -bare confluent-admin-analytics-dev
mv -f confluent-admin-analytics-dev-key.pem confluent-admin-analytics-dev.key
mv -f confluent-admin-analytics-dev.pem confluent-admin-analytics-dev.crt
cp confluent-admin-analytics-dev.key ../ansible/pki/confluent_kafka_server/analytics_dev
cp confluent-admin-analytics-dev.crt ../ansible/pki/confluent_kafka_server/analytics_dev


# Generate the etcd intermediate CA private key and certificates
cfssl gencert -initca etcd-ca-digital-dev-csr.json | cfssljson -bare etcd-ca-digital-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile intermediate_ca etcd-ca-digital-dev.csr | cfssljson -bare etcd-ca-digital-dev
mv -f etcd-ca-digital-dev-key.pem etcd-ca-digital-dev.key
mv -f etcd-ca-digital-dev.pem etcd-ca-digital-dev.crt
cp etcd-ca-digital-dev.crt ../ansible/pki/etcd/digital_dev
cp etcd-ca-digital-dev.key ../ansible/pki/etcd/digital_dev


# Generate the etcd cluster private key and certificate
cfssl genkey etcd-digital-dev-csr.json | cfssljson -bare etcd-digital-dev
cfssl sign -ca=etcd-ca-digital-dev.crt -ca-key=etcd-ca-digital-dev.key -config=etcd-ca-digital-dev-config.json -profile client_server etcd-digital-dev.csr | cfssljson -bare etcd-digital-dev
mv -f etcd-digital-dev-key.pem etcd-digital-dev.key
mv -f etcd-digital-dev.pem etcd-digital-dev.crt
cp etcd-digital-dev.key ../ansible/pki/etcd/digital_dev
cp etcd-digital-dev.crt ../ansible/pki/etcd/digital_dev


# Generate the etcd cluster hosts private keys and certificates
cfssl genkey etcd-digital-dev-01-csr.json | cfssljson -bare etcd-digital-dev-01
cfssl sign -ca=etcd-ca-digital-dev.crt -ca-key=etcd-ca-digital-dev.key -config=etcd-ca-digital-dev-config.json -profile client_server etcd-digital-dev-01.csr | cfssljson -bare etcd-digital-dev-01
mv -f etcd-digital-dev-01-key.pem etcd-digital-dev-01.key
mv -f etcd-digital-dev-01.pem etcd-digital-dev-01.crt
cp etcd-digital-dev-01.key ../ansible/pki/etcd/digital_dev
cp etcd-digital-dev-01.crt ../ansible/pki/etcd/digital_dev

cfssl genkey etcd-digital-dev-02-csr.json | cfssljson -bare etcd-digital-dev-02
cfssl sign -ca=etcd-ca-digital-dev.crt -ca-key=etcd-ca-digital-dev.key -config=etcd-ca-digital-dev-config.json -profile client_server etcd-digital-dev-02.csr | cfssljson -bare etcd-digital-dev-02
mv -f etcd-digital-dev-02-key.pem etcd-digital-dev-02.key
mv -f etcd-digital-dev-02.pem etcd-digital-dev-02.crt
cp etcd-digital-dev-02.key ../ansible/pki/etcd/digital_dev
cp etcd-digital-dev-02.crt ../ansible/pki/etcd/digital_dev

cfssl genkey etcd-digital-dev-03-csr.json | cfssljson -bare etcd-digital-dev-03
cfssl sign -ca=etcd-ca-digital-dev.crt -ca-key=etcd-ca-digital-dev.key -config=etcd-ca-digital-dev-config.json -profile client_server etcd-digital-dev-03.csr | cfssljson -bare etcd-digital-dev-03
mv -f etcd-digital-dev-03-key.pem etcd-digital-dev-03.key
mv -f etcd-digital-dev-03.pem etcd-digital-dev-03.crt
cp etcd-digital-dev-03.key ../ansible/pki/etcd/digital_dev
cp etcd-digital-dev-03.crt ../ansible/pki/etcd/digital_dev


# Generate the etcd client key and certificate
cfssl genkey etcd-client-digital-dev-csr.json | cfssljson -bare etcd-client-digital-dev
cfssl sign -ca=etcd-ca-digital-dev.crt -ca-key=etcd-ca-digital-dev.key -config=etcd-ca-digital-dev-config.json -profile client_server etcd-client-digital-dev.csr | cfssljson -bare etcd-client-digital-dev
mv -f etcd-client-digital-dev-key.pem etcd-client-digital-dev.key
mv -f etcd-client-digital-dev.pem etcd-client-digital-dev.crt
cp etcd-client-digital-dev.key ../ansible/pki/etcd/digital_dev
cp etcd-client-digital-dev.crt ../ansible/pki/etcd/digital_dev


# Generate the Kubernetes intermediate CA private key and certificate
cfssl gencert -initca k8s-ca-digital-dev-csr.json | cfssljson -bare k8s-ca-digital-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile intermediate_ca k8s-ca-digital-dev.csr | cfssljson -bare k8s-ca-digital-dev
mv -f k8s-ca-digital-dev-key.pem k8s-ca-digital-dev.key
mv -f k8s-ca-digital-dev.pem k8s-ca-digital-dev.crt
cp k8s-ca-digital-dev.crt ../ansible/pki/k8s_common/digital_dev
cp k8s-ca-digital-dev.key ../ansible/pki/k8s_master/digital_dev
cp k8s-ca-digital-dev.crt ../ansible/pki/k8s_master/digital_dev


# Generate the Kubernetes etcd intermediate CA private key and certificate
cfssl gencert -initca k8s-etcd-ca-digital-dev-csr.json | cfssljson -bare k8s-etcd-ca-digital-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile intermediate_ca k8s-etcd-ca-digital-dev.csr | cfssljson -bare k8s-etcd-ca-digital-dev
mv -f k8s-etcd-ca-digital-dev-key.pem k8s-etcd-ca-digital-dev.key
mv -f k8s-etcd-ca-digital-dev.pem k8s-etcd-ca-digital-dev.crt
cp k8s-etcd-ca-digital-dev.crt ../ansible/pki/k8s_common/digital_dev
cp k8s-etcd-ca-digital-dev.key ../ansible/pki/k8s_master/digital_dev
cp k8s-etcd-ca-digital-dev.crt ../ansible/pki/k8s_master/digital_dev


# Generate the Kubernetes etcd client private keys and certificates for connecting a Kubernetes cluster to an external etcd cluster
cfssl genkey k8s-m-digital-dev-01-csr.json | cfssljson -bare k8s-m-digital-dev-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-m-digital-dev-01.csr | cfssljson -bare k8s-m-digital-dev-01
mv -f k8s-m-digital-dev-01-key.pem k8s-m-digital-dev-01.key
mv -f k8s-m-digital-dev-01.pem k8s-m-digital-dev-01.crt
cp k8s-m-digital-dev-01.key ../ansible/pki/k8s_master/digital_dev
cp k8s-m-digital-dev-01.crt ../ansible/pki/k8s_master/digital_dev

cfssl genkey k8s-m-digital-dev-02-csr.json | cfssljson -bare k8s-m-digital-dev-02
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-m-digital-dev-02.csr | cfssljson -bare k8s-m-digital-dev-02
mv -f k8s-m-digital-dev-02-key.pem k8s-m-digital-dev-02.key
mv -f k8s-m-digital-dev-02.pem k8s-m-digital-dev-02.crt
cp k8s-m-digital-dev-02.key ../ansible/pki/k8s_master/digital_dev
cp k8s-m-digital-dev-02.crt ../ansible/pki/k8s_master/digital_dev

cfssl genkey k8s-m-digital-dev-03-csr.json | cfssljson -bare k8s-m-digital-dev-03
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-m-digital-dev-03.csr | cfssljson -bare k8s-m-digital-dev-03
mv -f k8s-m-digital-dev-03-key.pem k8s-m-digital-dev-03.key
mv -f k8s-m-digital-dev-03.pem k8s-m-digital-dev-03.crt
cp k8s-m-digital-dev-03.key ../ansible/pki/k8s_master/digital_dev
cp k8s-m-digital-dev-03.crt ../ansible/pki/k8s_master/digital_dev


# Generate the Istio intermediate CA private key and certificate
cfssl gencert -initca k8s-istio-ca-digital-dev-csr.json | cfssljson -bare k8s-istio-ca-digital-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile intermediate_ca k8s-istio-ca-digital-dev.csr | cfssljson -bare k8s-istio-ca-digital-dev
mv -f k8s-istio-ca-digital-dev-key.pem k8s-istio-ca-digital-dev.key
mv -f k8s-istio-ca-digital-dev.pem k8s-istio-ca-digital-dev.crt
cat k8s-istio-ca-digital-dev.crt > k8s-istio-ca-digital-dev-chain.crt
cat ca.crt >> k8s-istio-ca-digital-dev-chain.crt
cp k8s-istio-ca-digital-dev.key ../ansible/pki/k8s_istio/digital_dev
cp k8s-istio-ca-digital-dev.crt ../ansible/pki/k8s_istio/digital_dev
cp k8s-istio-ca-digital-dev-chain.crt ../ansible/pki/k8s_istio/digital_dev


# Generate the Istio ingress gateway private key and certificate
cfssl genkey k8s-istio-ingressgateway-digital-dev-csr.json | cfssljson -bare k8s-istio-ingressgateway-digital-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-istio-ingressgateway-digital-dev.csr | cfssljson -bare k8s-istio-ingressgateway-digital-dev
mv -f k8s-istio-ingressgateway-digital-dev-key.pem k8s-istio-ingressgateway-digital-dev.key
mv -f k8s-istio-ingressgateway-digital-dev.pem k8s-istio-ingressgateway-digital-dev.crt
cp k8s-istio-ingressgateway-digital-dev.key ../ansible/pki/k8s_istio/digital_dev
cp k8s-istio-ingressgateway-digital-dev.crt ../ansible/pki/k8s_istio/digital_dev


# Generate the default ingress gateway private key and certificate
cfssl genkey k8s-default-ingressgateway-digital-dev-csr.json | cfssljson -bare k8s-default-ingressgateway-digital-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-default-ingressgateway-digital-dev.csr | cfssljson -bare k8s-default-ingressgateway-digital-dev
mv -f k8s-default-ingressgateway-digital-dev-key.pem k8s-default-ingressgateway-digital-dev.key
mv -f k8s-default-ingressgateway-digital-dev.pem k8s-default-ingressgateway-digital-dev.crt
cp k8s-default-ingressgateway-digital-dev.key ../ansible/pki/k8s_istio/digital_dev
cp k8s-default-ingressgateway-digital-dev.crt ../ansible/pki/k8s_istio/digital_dev


# Generate the TopoLVM mutating webhook private key and certificate
cfssl genkey k8s-topolvm-mutatingwebhook-digital-dev-csr.json | cfssljson -bare k8s-topolvm-mutatingwebhook-digital-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-topolvm-mutatingwebhook-digital-dev.csr | cfssljson -bare k8s-topolvm-mutatingwebhook-digital-dev
mv -f k8s-topolvm-mutatingwebhook-digital-dev-key.pem k8s-topolvm-mutatingwebhook-digital-dev.key
mv -f k8s-topolvm-mutatingwebhook-digital-dev.pem k8s-topolvm-mutatingwebhook-digital-dev.crt
cp k8s-topolvm-mutatingwebhook-digital-dev.key ../ansible/pki/k8s_storage/digital_dev
cp k8s-topolvm-mutatingwebhook-digital-dev.crt ../ansible/pki/k8s_storage/digital_dev


# Generate the Elasticsearch private key and certificate
cfssl genkey k8s-elasticsearch-digital-dev-csr.json | cfssljson -bare k8s-elasticsearch-digital-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-elasticsearch-digital-dev.csr | cfssljson -bare k8s-elasticsearch-digital-dev
mv -f k8s-elasticsearch-digital-dev-key.pem k8s-elasticsearch-digital-dev.key
mv -f k8s-elasticsearch-digital-dev.pem k8s-elasticsearch-digital-dev.crt
cp k8s-elasticsearch-digital-dev.key ../ansible/pki/k8s_monitoring/digital_dev
cp k8s-elasticsearch-digital-dev.crt ../ansible/pki/k8s_monitoring/digital_dev


# Generate the Kibana private key and certificate
cfssl genkey k8s-kibana-digital-dev-csr.json | cfssljson -bare k8s-kibana-digital-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-kibana-digital-dev.csr | cfssljson -bare k8s-kibana-digital-dev
mv -f k8s-kibana-digital-dev-key.pem k8s-kibana-digital-dev.key
mv -f k8s-kibana-digital-dev.pem k8s-kibana-digital-dev.crt
cp k8s-kibana-digital-dev.key ../ansible/pki/k8s_monitoring/digital_dev
cp k8s-kibana-digital-dev.crt ../ansible/pki/k8s_monitoring/digital_dev


# Generate the Jaeger private key and certificate
cfssl genkey k8s-jaeger-digital-dev-csr.json | cfssljson -bare k8s-jaeger-digital-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server k8s-jaeger-digital-dev.csr | cfssljson -bare k8s-jaeger-digital-dev
mv -f k8s-jaeger-digital-dev-key.pem k8s-jaeger-digital-dev.key
mv -f k8s-jaeger-digital-dev.pem k8s-jaeger-digital-dev.crt
cp k8s-jaeger-digital-dev.key ../ansible/pki/k8s_monitoring/digital_dev
cp k8s-jaeger-digital-dev.crt ../ansible/pki/k8s_monitoring/digital_dev


# Generate the Kafka hosts private keys and certificates
cfssl genkey kafka-zkks-digital-dev-01-csr.json | cfssljson -bare kafka-zkks-digital-dev-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-zkks-digital-dev-01.csr | cfssljson -bare kafka-zkks-digital-dev-01
mv -f kafka-zkks-digital-dev-01-key.pem kafka-zkks-digital-dev-01.key
mv -f kafka-zkks-digital-dev-01.pem kafka-zkks-digital-dev-01.crt
cp kafka-zkks-digital-dev-01.key ../ansible/pki/kafka_server/digital_dev
cp kafka-zkks-digital-dev-01.crt ../ansible/pki/kafka_server/digital_dev
cp kafka-zkks-digital-dev-01.key ../ansible/pki/kafka_zookeeper/digital_dev
cp kafka-zkks-digital-dev-01.crt ../ansible/pki/kafka_zookeeper/digital_dev

cfssl genkey kafka-zkks-digital-dev-02-csr.json | cfssljson -bare kafka-zkks-digital-dev-02
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-zkks-digital-dev-02.csr | cfssljson -bare kafka-zkks-digital-dev-02
mv -f kafka-zkks-digital-dev-02-key.pem kafka-zkks-digital-dev-02.key
mv -f kafka-zkks-digital-dev-02.pem kafka-zkks-digital-dev-02.crt
cp kafka-zkks-digital-dev-02.key ../ansible/pki/kafka_server/digital_dev
cp kafka-zkks-digital-dev-02.crt ../ansible/pki/kafka_server/digital_dev
cp kafka-zkks-digital-dev-02.key ../ansible/pki/kafka_zookeeper/digital_dev
cp kafka-zkks-digital-dev-02.crt ../ansible/pki/kafka_zookeeper/digital_dev

cfssl genkey kafka-zkks-digital-dev-03-csr.json | cfssljson -bare kafka-zkks-digital-dev-03
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-zkks-digital-dev-03.csr | cfssljson -bare kafka-zkks-digital-dev-03
mv -f kafka-zkks-digital-dev-03-key.pem kafka-zkks-digital-dev-03.key
mv -f kafka-zkks-digital-dev-03.pem kafka-zkks-digital-dev-03.crt
cp kafka-zkks-digital-dev-03.key ../ansible/pki/kafka_server/digital_dev
cp kafka-zkks-digital-dev-03.crt ../ansible/pki/kafka_server/digital_dev
cp kafka-zkks-digital-dev-03.key ../ansible/pki/kafka_zookeeper/digital_dev
cp kafka-zkks-digital-dev-03.crt ../ansible/pki/kafka_zookeeper/digital_dev

cfssl genkey kafka-mm-digital-dev-01-csr.json | cfssljson -bare kafka-mm-digital-dev-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-mm-digital-dev-01.csr | cfssljson -bare kafka-mm-digital-dev-01
mv -f kafka-mm-digital-dev-01-key.pem kafka-mm-digital-dev-01.key
mv -f kafka-mm-digital-dev-01.pem kafka-mm-digital-dev-01.crt
cp kafka-mm-digital-dev-01.key ../ansible/pki/kafka_mirrormaker/digital_dev
cp kafka-mm-digital-dev-01.crt ../ansible/pki/kafka_mirrormaker/digital_dev

cfssl genkey kafka-zkks-analytics-dev-01-csr.json | cfssljson -bare kafka-zkks-analytics-dev-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-zkks-analytics-dev-01.csr | cfssljson -bare kafka-zkks-analytics-dev-01
mv -f kafka-zkks-analytics-dev-01-key.pem kafka-zkks-analytics-dev-01.key
mv -f kafka-zkks-analytics-dev-01.pem kafka-zkks-analytics-dev-01.crt
cp kafka-zkks-analytics-dev-01.key ../ansible/pki/kafka_server/analytics_dev
cp kafka-zkks-analytics-dev-01.crt ../ansible/pki/kafka_server/analytics_dev
cp kafka-zkks-analytics-dev-01.key ../ansible/pki/kafka_zookeeper/analytics_dev
cp kafka-zkks-analytics-dev-01.crt ../ansible/pki/kafka_zookeeper/analytics_dev

cfssl genkey kafka-zkks-analytics-dev-02-csr.json | cfssljson -bare kafka-zkks-analytics-dev-02
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-zkks-analytics-dev-02.csr | cfssljson -bare kafka-zkks-analytics-dev-02
mv -f kafka-zkks-analytics-dev-02-key.pem kafka-zkks-analytics-dev-02.key
mv -f kafka-zkks-analytics-dev-02.pem kafka-zkks-analytics-dev-02.crt
cp kafka-zkks-analytics-dev-02.key ../ansible/pki/kafka_server/analytics_dev
cp kafka-zkks-analytics-dev-02.crt ../ansible/pki/kafka_server/analytics_dev
cp kafka-zkks-analytics-dev-02.key ../ansible/pki/kafka_zookeeper/analytics_dev
cp kafka-zkks-analytics-dev-02.crt ../ansible/pki/kafka_zookeeper/analytics_dev

cfssl genkey kafka-zkks-analytics-dev-03-csr.json | cfssljson -bare kafka-zkks-analytics-dev-03
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-zkks-analytics-dev-03.csr | cfssljson -bare kafka-zkks-analytics-dev-03
mv -f kafka-zkks-analytics-dev-03-key.pem kafka-zkks-analytics-dev-03.key
mv -f kafka-zkks-analytics-dev-03.pem kafka-zkks-analytics-dev-03.crt
cp kafka-zkks-analytics-dev-03.key ../ansible/pki/kafka_server/analytics_dev
cp kafka-zkks-analytics-dev-03.crt ../ansible/pki/kafka_server/analytics_dev
cp kafka-zkks-analytics-dev-03.key ../ansible/pki/kafka_zookeeper/analytics_dev
cp kafka-zkks-analytics-dev-03.crt ../ansible/pki/kafka_zookeeper/analytics_dev

cfssl genkey kafka-mm-analytics-dev-01-csr.json | cfssljson -bare kafka-mm-analytics-dev-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server kafka-mm-analytics-dev-01.csr | cfssljson -bare kafka-mm-analytics-dev-01
mv -f kafka-mm-analytics-dev-01-key.pem kafka-mm-analytics-dev-01.key
mv -f kafka-mm-analytics-dev-01.pem kafka-mm-analytics-dev-01.crt
cp kafka-mm-analytics-dev-01.key ../ansible/pki/kafka_mirrormaker/analytics_dev
cp kafka-mm-analytics-dev-01.crt ../ansible/pki/kafka_mirrormaker/analytics_dev


# Generate the Kafka Admin certificates
cfssl genkey kafka-admin-digital-dev-csr.json | cfssljson -bare kafka-admin-digital-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client kafka-admin-digital-dev.csr | cfssljson -bare kafka-admin-digital-dev
mv -f kafka-admin-digital-dev-key.pem kafka-admin-digital-dev.key
mv -f kafka-admin-digital-dev.pem kafka-admin-digital-dev.crt
cp kafka-admin-digital-dev.key ../ansible/pki/kafka_server/digital_dev
cp kafka-admin-digital-dev.crt ../ansible/pki/kafka_server/digital_dev

cfssl genkey kafka-admin-analytics-dev-csr.json | cfssljson -bare kafka-admin-analytics-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client kafka-admin-analytics-dev.csr | cfssljson -bare kafka-admin-analytics-dev
mv -f kafka-admin-analytics-dev-key.pem kafka-admin-analytics-dev.key
mv -f kafka-admin-analytics-dev.pem kafka-admin-analytics-dev.crt
cp kafka-admin-analytics-dev.key ../ansible/pki/kafka_server/analytics_dev
cp kafka-admin-analytics-dev.crt ../ansible/pki/kafka_server/analytics_dev


# Generate the monitoring hosts private keys and certificates
cfssl genkey monitoring-dev-csr.json | cfssljson -bare monitoring-dev
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server monitoring-dev.csr | cfssljson -bare monitoring-dev
mv -f monitoring-dev-key.pem monitoring-dev.key
mv -f monitoring-dev.pem monitoring-dev.crt
cp monitoring-dev.key ../ansible/pki/burrow/dev
cp monitoring-dev.crt ../ansible/pki/burrow/dev


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








#   ____  _        _  _____ _____ ___  ____  __  __ 
#  |  _ \| |      / \|_   _|  ___/ _ \|  _ \|  \/  |
#  | |_) | |     / _ \ | | | |_ | | | | |_) | |\/| |
#  |  __/| |___ / ___ \| | |  _|| |_| |  _ <| |  | |
#  |_|   |_____/_/   \_\_| |_|   \___/|_| \_\_|  |_|
#                                                   

# Generate the Confluent hosts private keys and certificates
cfssl genkey confluent-zk-local-01-csr.json | cfssljson -bare confluent-zk-local-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-zk-local-01.csr | cfssljson -bare confluent-zk-local-01
mv -f confluent-zk-local-01-key.pem confluent-zk-local-01.key
mv -f confluent-zk-local-01.pem confluent-zk-local-01.crt
cp confluent-zk-local-01.key ../ansible/pki/confluent_kafka_server/local
cp confluent-zk-local-01.crt ../ansible/pki/confluent_kafka_server/local
cp confluent-zk-local-01.key ../ansible/pki/confluent_zookeeper/local
cp confluent-zk-local-01.crt ../ansible/pki/confluent_zookeeper/local

cfssl genkey confluent-zk-local-02-csr.json | cfssljson -bare confluent-zk-local-02
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-zk-local-02.csr | cfssljson -bare confluent-zk-local-02
mv -f confluent-zk-local-02-key.pem confluent-zk-local-02.key
mv -f confluent-zk-local-02.pem confluent-zk-local-02.crt
cp confluent-zk-local-02.key ../ansible/pki/confluent_kafka_server/local
cp confluent-zk-local-02.crt ../ansible/pki/confluent_kafka_server/local
cp confluent-zk-local-02.key ../ansible/pki/confluent_zookeeper/local
cp confluent-zk-local-02.crt ../ansible/pki/confluent_zookeeper/local

cfssl genkey confluent-zk-local-03-csr.json | cfssljson -bare confluent-zk-local-03
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-zk-local-03.csr | cfssljson -bare confluent-zk-local-03
mv -f confluent-zk-local-03-key.pem confluent-zk-local-03.key
mv -f confluent-zk-local-03.pem confluent-zk-local-03.crt
cp confluent-zk-local-03.key ../ansible/pki/confluent_kafka_server/local
cp confluent-zk-local-03.crt ../ansible/pki/confluent_kafka_server/local
cp confluent-zk-local-03.key ../ansible/pki/confluent_zookeeper/local
cp confluent-zk-local-03.crt ../ansible/pki/confluent_zookeeper/local

cfssl genkey confluent-ks-local-01-csr.json | cfssljson -bare confluent-ks-local-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-ks-local-01.csr | cfssljson -bare confluent-ks-local-01
mv -f confluent-ks-local-01-key.pem confluent-ks-local-01.key
mv -f confluent-ks-local-01.pem confluent-ks-local-01.crt
cp confluent-ks-local-01.key ../ansible/pki/confluent_kafka_server/local
cp confluent-ks-local-01.crt ../ansible/pki/confluent_kafka_server/local
cp confluent-ks-local-01.key ../ansible/pki/confluent_zookeeper/local
cp confluent-ks-local-01.crt ../ansible/pki/confluent_zookeeper/local

cfssl genkey confluent-ks-local-02-csr.json | cfssljson -bare confluent-ks-local-02
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-ks-local-02.csr | cfssljson -bare confluent-ks-local-02
mv -f confluent-ks-local-02-key.pem confluent-ks-local-02.key
mv -f confluent-ks-local-02.pem confluent-ks-local-02.crt
cp confluent-ks-local-02.key ../ansible/pki/confluent_kafka_server/local
cp confluent-ks-local-02.crt ../ansible/pki/confluent_kafka_server/local
cp confluent-ks-local-02.key ../ansible/pki/confluent_zookeeper/local
cp confluent-ks-local-02.crt ../ansible/pki/confluent_zookeeper/local

cfssl genkey confluent-ks-local-03-csr.json | cfssljson -bare confluent-ks-local-03
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-ks-local-03.csr | cfssljson -bare confluent-ks-local-03
mv -f confluent-ks-local-03-key.pem confluent-ks-local-03.key
mv -f confluent-ks-local-03.pem confluent-ks-local-03.crt
cp confluent-ks-local-03.key ../ansible/pki/confluent_kafka_server/local
cp confluent-ks-local-03.crt ../ansible/pki/confluent_kafka_server/local
cp confluent-ks-local-03.key ../ansible/pki/confluent_zookeeper/local
cp confluent-ks-local-03.crt ../ansible/pki/confluent_zookeeper/local

cfssl genkey confluent-sr-local-01-csr.json | cfssljson -bare confluent-sr-local-01
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-sr-local-01.csr | cfssljson -bare confluent-sr-local-01
mv -f confluent-sr-local-01-key.pem confluent-sr-local-01.key
mv -f confluent-sr-local-01.pem confluent-sr-local-01.crt
cp confluent-sr-local-01.key ../ansible/pki/confluent_kafka_server/local
cp confluent-sr-local-01.crt ../ansible/pki/confluent_kafka_server/local
cp confluent-sr-local-01.key ../ansible/pki/confluent_zookeeper/local
cp confluent-sr-local-01.crt ../ansible/pki/confluent_zookeeper/local

cfssl genkey confluent-sr-local-02-csr.json | cfssljson -bare confluent-sr-local-02
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-sr-local-02.csr | cfssljson -bare confluent-sr-local-02
mv -f confluent-sr-local-02-key.pem confluent-sr-local-02.key
mv -f confluent-sr-local-02.pem confluent-sr-local-02.crt
cp confluent-sr-local-02.key ../ansible/pki/confluent_kafka_server/local
cp confluent-sr-local-02.crt ../ansible/pki/confluent_kafka_server/local
cp confluent-sr-local-02.key ../ansible/pki/confluent_zookeeper/local
cp confluent-sr-local-02.crt ../ansible/pki/confluent_zookeeper/local

cfssl genkey confluent-sr-local-03-csr.json | cfssljson -bare confluent-sr-local-03
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client_server confluent-sr-local-03.csr | cfssljson -bare confluent-sr-local-03
mv -f confluent-sr-local-03-key.pem confluent-sr-local-03.key
mv -f confluent-sr-local-03.pem confluent-sr-local-03.crt
cp confluent-sr-local-03.key ../ansible/pki/confluent_kafka_server/local
cp confluent-sr-local-03.crt ../ansible/pki/confluent_kafka_server/local
cp confluent-sr-local-03.key ../ansible/pki/confluent_zookeeper/local
cp confluent-sr-local-03.crt ../ansible/pki/confluent_zookeeper/local

cfssl genkey confluent-admin-local-csr.json | cfssljson -bare confluent-admin-local
cfssl sign -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile client confluent-admin-local.csr | cfssljson -bare confluent-admin-local
mv -f confluent-admin-local-key.pem confluent-admin-local.key
mv -f confluent-admin-local.pem confluent-admin-local.crt
cp confluent-admin-local.key ../ansible/pki/confluent_kafka_server/local
cp confluent-admin-local.crt ../ansible/pki/confluent_kafka_server/local



