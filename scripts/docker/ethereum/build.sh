BASE_DIR=`dirname $0`"/../../.."
DOCKER_MANIFEST_DIR=${BASE_DIR}/manifests/docker/ethereum

docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile.base -t kmgreen2/ethereum-base:latest
docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile.bootnode -t kmgreen2/ethereum-boot:latest
docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile.enode_bootstrap -t kmgreen2/ethereum-enode-bootstrap:latest
docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile.membernode -t kmgreen2/ethereum-member:latest
docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile.miner -t kmgreen2/ethereum-miner:latest

if [[ $1 == "push" ]]; then
    docker push kmgreen2/ethereum-base
    docker push kmgreen2/ethereum-boot
    docker push kmgreen2/ethereum-enode-bootstrap
    docker push kmgreen2/ethereum-member
    docker push kmgreen2/ethereum-miner
fi

