BASE_DIR=`dirname $0`"/../../.."
DOCKER_MANIFEST_DIR=${BASE_DIR}/manifests/docker/gossip
BINS="addpeer server createevent dumpevents"

for bin in ${BINS}; do
    sudo docker build --build-arg GITHUB_TOKEN=`cat ~/.gitaccess` ${BASE_DIR} -f ${DOCKER_MANIFEST_DIR}/Dockerfile.${bin} -t kmgreen2/gossip-${bin}:latest

    if [[ $? != "0" ]]; then
        break
    fi

    if [[ $1 == "push" ]]; then
        sudo docker push kmgreen2/gossip-${bin}:latest
    fi
done
