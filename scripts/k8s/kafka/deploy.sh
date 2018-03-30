BASE_DIR=`dirname $0`"/../../.."
KAFKA_K8S_MANIFEST_DIR=${BASE_DIR}/manifests/k8s/kafka
ZK_K8S_MANIFEST_DIR=${BASE_DIR}/manifests/k8s/zk


kubectl apply -f ${ZK_K8S_MANIFEST_DIR}/k8s-zk-manifest.yaml

IS_READY=`kubectl get pods -n kafka | grep 'zk' | grep 'Running'`
NUM_TRIES=0
while [[ -z ${IS_READY} ]]; do
    if (( NUM_TRIES > 3 )); then
        echo "ZK is still not available...  Bailing..."
        exit
    fi
    echo "ZK is still not available...  Waiting to retry..."
    sleep 30
    IS_READY=`kubectl get pods -n kafka | grep 'zk' | grep 'Running'`
    let NUM_TRIES=${NUM_TRIES}+1
done

kubectl apply -f ${KAFKA_K8S_MANIFEST_DIR}/k8s-kafka-manifest.yaml
