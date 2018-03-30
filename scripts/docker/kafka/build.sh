BASE_DIR=`dirname $0`"/../../.."
DOCKER_MANIFEST_DIR=${BASE_DIR}/manifests/docker/kafka

docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile -t kmgreen2/kafka:0.10.2.1

if [[ $1 == "push" ]]; then
    docker push kmgreen2/kafka:0.10.2.1
fi

