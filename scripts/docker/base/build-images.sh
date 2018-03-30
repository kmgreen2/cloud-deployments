BASE_DIR=`dirname $0`"/../../.."
DOCKER_MANIFEST_DIR=${BASE_DIR}/manifests/docker/base

if [[ -z ${ARG_AWS_ACCESS_KEY_ID} ]]; then
    echo -n "Enter AWS Access Key (then hit enter): "
    read -s ARG_AWS_ACCESS_KEY_ID
    echo
fi

if [[ -z ${ARG_AWS_SECRET_ACCESS_KEY} ]]; then
    echo -n "Enter AWS Secret Key (then hit enter): "
    read -s ARG_AWS_SECRET_ACCESS_KEY
    echo
fi

sudo docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile -t 'sl7-aws-mgmt:latest' --build-arg ARG_AWS_ACCESS_KEY_ID="${ARG_AWS_ACCESS_KEY_ID}" --build-arg ARG_AWS_SECRET_ACCESS_KEY="${ARG_AWS_SECRET_ACCESS_KEY}"

sudo docker build ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile.echoserver -t 'docker.io/kmgreen2/sl7-echoserver'
