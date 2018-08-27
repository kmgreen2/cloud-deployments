#!/bin/bash

if [[ -z $1  || -z $2 ]]; then
    echo "Usage: $0 <master> <peer port>"
    exit 1
fi

MASTER=$1
PORT=$2

PEER_IPS=`kubectl get pods -n gossip-server -o wide | grep 'gossip-server' | awk '{print $6;}'`

for peer in `echo ${PEER_IPS}`; do
    echo "Events for $peer:"
    ssh -i /root/.ssh/id_rsa_instance -o StrictHostKeyChecking=no admin@${MASTER} "sudo docker run kmgreen2/gossip-dumpevents /dumpevents -server ${peer}:${PORT}"
    echo "=================="
done

