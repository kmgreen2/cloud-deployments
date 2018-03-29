BASE_DIR=`dirname $0`"/../.."
MANIFEST_DIR=${BASE_DIR}/manifests/packer
packer build \
    -var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
    -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
    ${MANIFEST_DIR}/build-dumbstack-ami.json
