#!/bin/sh

# Execute the following command to allow the script to be executed on MacOS:
#   xattr -d com.apple.quarantine generate-certificates.sh

mkdir -p ../ansible/roles/etcd/files/pki/local
mkdir -p ../ansible/roles/k8s_common/files/pki/local
mkdir -p ../ansible/roles/k8s_istio/files/pki/local
mkdir -p ../ansible/roles/k8s_master/files/pki/local
mkdir -p ../ansible/roles/k8s_monitoring/files/pki/local
mkdir -p ../ansible/roles/k8s_operators/files/pki/local
mkdir -p ../ansible/roles/k8s_storage/files/pki/local


# Generate the Root CA private key and certificate
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
mv -f ca.pem ca.crt
mv -f ca-key.pem ca.key
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
cfssl gencert -ca=etcd-local-ca.crt -ca-key=etcd-local-ca.key -config=etcd-local-ca-config.json -profile=client_server etcd-local-csr.json | cfssljson -bare etcd-local
mv -f etcd-local-key.pem etcd-local.key
mv -f etcd-local.pem etcd-local.crt
cp etcd-local.key ../ansible/roles/etcd/files/pki/local
cp etcd-local.crt ../ansible/roles/etcd/files/pki/local


# Generate the etcd cluster peer private keys and certificates
cfssl gencert -ca=etcd-local-ca.crt -ca-key=etcd-local-ca.key -config=etcd-local-ca-config.json -profile=client_server etcd-local-01-etcd-peer-csr.json | cfssljson -bare etcd-local-01-etcd-peer
mv -f etcd-local-01-etcd-peer-key.pem etcd-local-01-etcd-peer.key
mv -f etcd-local-01-etcd-peer.pem etcd-local-01-etcd-peer.crt
cp etcd-local-01-etcd-peer.key ../ansible/roles/etcd/files/pki/local
cp etcd-local-01-etcd-peer.crt ../ansible/roles/etcd/files/pki/local

cfssl gencert -ca=etcd-local-ca.crt -ca-key=etcd-local-ca.key -config=etcd-local-ca-config.json -profile=client_server etcd-local-02-etcd-peer-csr.json | cfssljson -bare etcd-local-02-etcd-peer
mv -f etcd-local-02-etcd-peer-key.pem etcd-local-02-etcd-peer.key
mv -f etcd-local-02-etcd-peer.pem etcd-local-02-etcd-peer.crt
cp etcd-local-02-etcd-peer.key ../ansible/roles/etcd/files/pki/local
cp etcd-local-02-etcd-peer.crt ../ansible/roles/etcd/files/pki/local

cfssl gencert -ca=etcd-local-ca.crt -ca-key=etcd-local-ca.key -config=etcd-local-ca-config.json -profile=client_server etcd-local-03-etcd-peer-csr.json | cfssljson -bare etcd-local-03-etcd-peer
mv -f etcd-local-03-etcd-peer-key.pem etcd-local-03-etcd-peer.key
mv -f etcd-local-03-etcd-peer.pem etcd-local-03-etcd-peer.crt
cp etcd-local-03-etcd-peer.key ../ansible/roles/etcd/files/pki/local
cp etcd-local-03-etcd-peer.crt ../ansible/roles/etcd/files/pki/local


# Generate the etcd client key and certificate
cfssl gencert -ca=etcd-local-ca.crt -ca-key=etcd-local-ca.key -config=etcd-local-ca-config.json -profile=client etcd-local-client-csr.json | cfssljson -bare etcd-local-client
mv -f etcd-local-client-key.pem etcd-local-client.key
mv -f etcd-local-client.pem etcd-local-client.crt
cp etcd-local-client.key ../ansible/roles/etcd/files/pki/local
cp etcd-local-client.crt ../ansible/roles/etcd/files/pki/local


# Generate the Kubernetes etcd client private keys and certificates for connecting a Kubernetes cluster to an external etcd cluster
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile=client k8s-local-m-01-etcd-client-csr.json | cfssljson -bare k8s-local-m-01-etcd-client
mv -f k8s-local-m-01-etcd-client-key.pem k8s-local-m-01-etcd-client.key
mv -f k8s-local-m-01-etcd-client.pem k8s-local-m-01-etcd-client.crt
cp k8s-local-m-01-etcd-client.key ../ansible/roles/k8s_master/files/pki/local
cp k8s-local-m-01-etcd-client.crt ../ansible/roles/k8s_master/files/pki/local

cfssl gencert -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile=client k8s-local-m-02-etcd-client-csr.json | cfssljson -bare k8s-local-m-02-etcd-client
mv -f k8s-local-m-02-etcd-client-key.pem k8s-local-m-02-etcd-client.key
mv -f k8s-local-m-02-etcd-client.pem k8s-local-m-02-etcd-client.crt
cp k8s-local-m-02-etcd-client.key ../ansible/roles/k8s_master/files/pki/local
cp k8s-local-m-02-etcd-client.crt ../ansible/roles/k8s_master/files/pki/local

cfssl gencert -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile=client k8s-local-m-03-etcd-client-csr.json | cfssljson -bare k8s-local-m-03-etcd-client
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
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile=client_server k8s-local-istio-ingressgateway-csr.json | cfssljson -bare k8s-local-istio-ingressgateway
mv -f k8s-local-istio-ingressgateway-key.pem k8s-local-istio-ingressgateway.key
mv -f k8s-local-istio-ingressgateway.pem k8s-local-istio-ingressgateway.crt
cp k8s-local-istio-ingressgateway.key ../ansible/roles/k8s_istio/files/pki/local
cp k8s-local-istio-ingressgateway.crt ../ansible/roles/k8s_istio/files/pki/local


# Generate the default ingress gateway private key and certificate
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile=client_server k8s-local-default-ingressgateway-csr.json | cfssljson -bare k8s-local-default-ingressgateway
mv -f k8s-local-default-ingressgateway-key.pem k8s-local-default-ingressgateway.key
mv -f k8s-local-default-ingressgateway.pem k8s-local-default-ingressgateway.crt
cp k8s-local-default-ingressgateway.key ../ansible/roles/k8s_istio/files/pki/local
cp k8s-local-default-ingressgateway.crt ../ansible/roles/k8s_istio/files/pki/local


# Generate the TopoLVM mutating webhook private key and certificate
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile=client_server k8s-local-topolvm-mutatingwebhook-csr.json | cfssljson -bare k8s-local-topolvm-mutatingwebhook
mv -f k8s-local-topolvm-mutatingwebhook-key.pem k8s-local-topolvm-mutatingwebhook.key
mv -f k8s-local-topolvm-mutatingwebhook.pem k8s-local-topolvm-mutatingwebhook.crt
cp k8s-local-topolvm-mutatingwebhook.key ../ansible/roles/k8s_storage/files/pki/local
cp k8s-local-topolvm-mutatingwebhook.crt ../ansible/roles/k8s_storage/files/pki/local


# Generate the Elasticsearch private key and certificate
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile=client_server k8s-local-elasticsearch-csr.json | cfssljson -bare k8s-local-elasticsearch
mv -f k8s-local-elasticsearch-key.pem k8s-local-elasticsearch.key
mv -f k8s-local-elasticsearch.pem k8s-local-elasticsearch.crt
cp k8s-local-elasticsearch.key ../ansible/roles/k8s_monitoring/files/pki/local
cp k8s-local-elasticsearch.crt ../ansible/roles/k8s_monitoring/files/pki/local


# Generate the Kibana private key and certificate
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile=client_server k8s-local-kibana-csr.json | cfssljson -bare k8s-local-kibana
mv -f k8s-local-kibana-key.pem k8s-local-kibana.key
mv -f k8s-local-kibana.pem k8s-local-kibana.crt
cp k8s-local-kibana.key ../ansible/roles/k8s_monitoring/files/pki/local
cp k8s-local-kibana.crt ../ansible/roles/k8s_monitoring/files/pki/local


# Generate the Jaeger private key and certificate
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile=client_server k8s-local-jaeger-csr.json | cfssljson -bare k8s-local-jaeger
mv -f k8s-local-jaeger-key.pem k8s-local-jaeger.key
mv -f k8s-local-jaeger.pem k8s-local-jaeger.crt
cp k8s-local-jaeger.key ../ansible/roles/k8s_monitoring/files/pki/local
cp k8s-local-jaeger.crt ../ansible/roles/k8s_monitoring/files/pki/local


# Generate the Kafka Zookeeper private keys and certificates
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile=client_server kafka-zookeeper-local-csr.json | cfssljson -bare kafka-zookeeper-local
mv -f kafka-zookeeper-local-key.pem kafka-zookeeper-local.key
mv -f kafka-zookeeper-local.pem kafka-zookeeper-local.crt
cp kafka-zookeeper-local.key ../ansible/roles/kafka_zookeeper/files/pki/local
cp kafka-zookeeper-local.crt ../ansible/roles/kafka_zookeeper/files/pki/local







