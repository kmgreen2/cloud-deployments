#!/bin/bash

set -e

ETH_BOOT_NODE=""
NUM_TRIES=0

while [[ -z $ETH_BOOT_NODE ]]; do
    ETH_BOOT_NODE=`curl http://ethereum-boot.ethereum.svc.cluster.local:80`
    if (( NUM_TRIES > 3 )); then
        echo "Could not connect to the bootstrap server: ethereum-boot.ethereum.svc.cluster.local:80"
        exit 1
    fi
    let NUM_TRIES=${NUM_TRIES}+1
done

echo "changeme" > $ETH_DATA_DIR/.miner.pwd
export ETHERBASE="2dbeb96b6fdf54834b3c33cd50e1349ac7bef7c6"

mkdir -p $ETH_DATA_DIR/keystore
cp $ETH_DATA_DIR/keystore.json $ETH_DATA_DIR/keystore/UTC--2018-04-06T01-53-33.216988388Z--$ETHERBASE

if [[ -n $ETH_DEBUG ]]; then
    DLV="dlv --headless=true --listen=:$ETH_DEBUG_PORT --log --api-version=2 exec"
    CMD=$DLV" geth -- --datadir="$ETH_DATA_DIR" --networkid 1337 --bootnodes $ETH_BOOT_NODE --mine --minerthreads=1 --etherbase=${ETHERBASE} > $ETH_LOG_DIR/miner.log 2>&1"
else
    CMD="geth --datadir="$ETH_DATA_DIR" --networkid 1337 --bootnodes $ETH_BOOT_NODE --mine --minerthreads=1 --etherbase=${ETHERBASE} > $ETH_LOG_DIR/miner.log 2>&1"
fi


exec sh -c "$CMD"
