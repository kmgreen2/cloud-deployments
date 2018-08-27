#!/bin/bash

if [[ -z $1  || -z $2 ]]; then
    echo "Usage: $0 <kubenetes master ip> <peer port>"
    exit 1
fi

MASTER=$1
PORT=$2

PEER_IPS=`kubectl get pods -n gossip-server -o wide | grep 'gossip-server' | awk '{print $6;}'`

for server in `echo $PEER_IPS`; do
    for peer in `echo $PEER_IPS`; do
        if [[ ${peer} != ${server} ]]; then
            echo "Peering ${server} with ${peer}"
            ssh -i /root/.ssh/id_rsa_instance -o StrictHostKeyChecking=no admin@${MASTER} "sudo docker run kmgreen2/gossip-addpeer /addpeer -server ${server}:${PORT} -peer ${peer}:${PORT}"
        fi
    done
done

