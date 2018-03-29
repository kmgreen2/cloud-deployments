ZONES=us-west-2a
export NAME=kmg-cluster.k8s.local

kops -v4 create cluster \
  --zones $ZONES \
  --master-zones $ZONES \
  --master-size m4.large \
  --node-size m4.large \
  --networking calico \
  --name ${NAME}
