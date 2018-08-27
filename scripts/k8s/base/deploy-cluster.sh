BASE_DIR=`dirname $0`"/../../.."
K8S_MANIFEST_DIR=${BASE_DIR}/manifests/k8s/base

export NAME=kmg-cluster.k8s.local

kops create -f ${K8S_MANIFEST_DIR}/kops-aws-cluster.yaml
kops create secret --name $NAME sshpublickey admin -i ~/.ssh/id_rsa_instance.pub
kops update cluster $NAME --yes
kops rolling-update cluster $NAME --yes --cloudonly
