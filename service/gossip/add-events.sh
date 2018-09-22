#!/bin/bash

if [[ -z $1  || -z $2 || -z $3 || -z $4 ]]; then
    echo "Usage: $0 <master> <start timestamp> <num events> <batch size> <peer port>"
    exit 1
fi

MASTER=$1
let START=$2
let NUM_EVENTS=$3
let NUM_EVENTS=$NUM_EVENTS+$2
let BATCH_SIZE=$4
PORT=$5

declare -a PEER_IPS=(`kubectl get pods -n gossip-server -o wide | grep 'gossip-server' | awk '{print $6;}'`)

let i=${START}
while (( i < NUM_EVENTS )); do
    peer=${PEER_IPS[$RANDOM % ${#PEER_IPS[@]}]}
    echo "Adding event $i to $peer"
    ssh -i /root/.ssh/id_rsa_instance -o StrictHostKeyChecking=no admin@${MASTER} "sudo docker run kmgreen2/gossip-createevent /createevent -server ${peer}:${PORT} -event evt-$i" &
    let i=$i+1
    if (( i % BATCH_SIZE == 0 )); then
        echo "Waiting for child processes to complete..."
        wait
        if [[ $? != "0" ]]; then
            echo "Child error!  Exiting..."
            exit 1
        fi
    fi
done

