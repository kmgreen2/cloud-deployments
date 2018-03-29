BASE_DIR=`dirname $0`"/../.."
BASE_DIR=`realpath ${BASE_DIR}`
ROOT_MNT=${BASE_DIR}/root-dir
MANIFEST_MNT=${BASE_DIR}/manifests
SCRIPTS_MNT=${BASE_DIR}/scripts
CONFIG_MNT=${BASE_DIR}/config
SERVICE_MNT=${BASE_DIR}/service
mkdir -p ${ROOT_MNT} 
mkdir -p ${ROOT_MNT}/.ssh/
cp ./id_rsa.pub ${ROOT_MNT}/.ssh/
cp ./id_rsa_instance.pub ${ROOT_MNT}/.ssh/
cp ./id_rsa_instance ${ROOT_MNT}/.ssh/
cp -r ~/.aws ${ROOT_MNT}/
sudo docker run -v ${ROOT_MNT}:/root:z \
    -v ${MANIFEST_MNT}:/manifests:z \
    -v ${SCRIPTS_MNT}:/scripts:ro \
    -v ${CONFIG_MNT}:/config:ro \
    -v ${SERVICE_MNT}:/service:ro \
    -e USERID=$UID \
    -it sl7-aws-mgmt:latest bash
