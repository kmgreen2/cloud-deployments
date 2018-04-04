BASE_DIR=`dirname $0`"/../../.."
DOCKER_MANIFEST_DIR=${BASE_DIR}/manifests/docker/ethereum

sudo docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile.base -t kmgreen2/ethereum-base:latest
sudo docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile.bootnode -t kmgreen2/ethereum-boot:latest
sudo docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile.enode_bootstrap -t kmgreen2/ethereum-enode-bootstrap:latest
sudo docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile.membernode -t kmgreen2/ethereum-member:latest
sudo docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile.miner -t kmgreen2/ethereum-miner:latest
sudo docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile.ethstats -t kmgreen2/ethereum-ethstats:latest
sudo docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile.ethnet-agent -t kmgreen2/ethereum-ethnet-agent:latest

if [[ $1 == "push" ]]; then
    sudo docker push kmgreen2/ethereum-base
    sudo docker push kmgreen2/ethereum-boot
    sudo docker push kmgreen2/ethereum-enode-bootstrap
    sudo docker push kmgreen2/ethereum-member
    sudo docker push kmgreen2/ethereum-miner
    sudo docker push kmgreen2/ethereum-ethstats
    sudo docker push kmgreen2/ethereum-ethnet-agent
fi

