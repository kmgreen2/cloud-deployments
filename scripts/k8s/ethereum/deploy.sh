BASE_DIR=`dirname $0`"/../../.."
K8S_MANIFEST_DIR=${BASE_DIR}/manifests/k8s/ethereum

# This is just basic stuff like the namespace
kubectl apply -f ${K8S_MANIFEST_DIR}/k8s-ethereum-base.yaml

# This is the bootnode, plus the service the members use to bootstrap
# to the private network
kubectl apply -f ${K8S_MANIFEST_DIR}/k8s-bootnode-manifest.yaml

IS_READY=`kubectl get pods -n ethereum | grep 'ethereum-boot' | grep 'Running'`
NUM_TRIES=0
while [[ -z ${IS_READY} ]]; do
    if (( NUM_TRIES > 5 )); then
        echo "Bootnode is still not available...  Bailing..."
        exit
    fi
    echo "Bootnode is not available...  Waiting to retry..."
    sleep 30
    IS_READY=`kubectl get pods -n ethereum | grep 'ethereum-boot' | grep 'Running'`
    let NUM_TRIES=${NUM_TRIES}+1
done

# Members and miners can be added once boot nodes are up
kubectl apply -f ${K8S_MANIFEST_DIR}/k8s-membernode-manifest.yaml
kubectl apply -f ${K8S_MANIFEST_DIR}/k8s-miner-manifest.yaml

