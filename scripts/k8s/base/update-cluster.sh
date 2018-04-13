BASE_DIR=`dirname $0`"/../../.."
K8S_MANIFEST_DIR=${BASE_DIR}/manifests/k8s/base

export NAME=kmg-cluster.k8s.local

kops replace -f ${K8S_MANIFEST_DIR}/kops-aws-cluster.yaml
kops update cluster $NAME --yes
kops rolling-update cluster $NAME --yes
