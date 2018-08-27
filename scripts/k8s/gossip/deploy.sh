BASE_DIR=`dirname $0`"/../../.."
K8S_MANIFEST_DIR=${BASE_DIR}/manifests/k8s/gossip

kubectl apply -f ${K8S_MANIFEST_DIR}/k8s-server.yaml
