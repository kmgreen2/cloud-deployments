BASE_DIR=`dirname $0`"/../../.."
DOCKER_MANIFEST_DIR=${BASE_DIR}/manifests/docker/zk

docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile -t kmgreen2/zookeeper:3.4.11

if [[ $1 == "push" ]]; then
    docker push kmgreen2/zookeeper:3.4.11
fi

