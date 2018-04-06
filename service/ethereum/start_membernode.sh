#!/bin/bash
  
set -e

ETH_BOOT_NODE=""
NUM_TRIES=0

while [[ -z $ETH_BOOT_NODE ]]; do
    ETH_BOOT_NODE=`curl --max-time 30 http://ethereum-boot.ethereum.svc.cluster.local:80`
    if (( NUM_TRIES > 5 )); then
        echo "Could not connect to the bootstrap server: ethereum-boot.ethereum.svc.cluster.local:80"
        exit 1
    fi
    let NUM_TRIES=${NUM_TRIES}+1
done

echo "changeme" > $ETH_DATA_DIR/.member.pwd
export ETHERBASE="2dbeb96b6fdf54834b3c33cd50e1349ac7bef7c6"

# Create genesis block
geth --datadir="$ETH_DATA_DIR" init $ETH_DATA_DIR/genesis.json

# Import the default account
cp $ETH_DATA_DIR/keystore.json $ETH_DATA_DIR/keystore/UTC--2018-04-06T01-53-33.216988388Z--$ETHERBASE

if [[ -n $ETH_DEBUG ]]; then
    DLV="dlv --headless=true --listen=:$ETH_DEBUG_PORT --log --api-version=2 exec"
    CMD=$DLV" geth -- --datadir="$ETH_DATA_DIR" -verbosity 6 --port $ETH_PORT --rpc --rpcport $ETH_RPC_PORT --networkid 1337 --bootnodes $ETH_BOOT_NODE > $ETH_LOG_DIR/membernode.log 2>&1"
else
    CMD="geth --datadir="$ETH_DATA_DIR" -verbosity 6 --port $ETH_PORT --rpc --rpcport $ETH_RPC_PORT --networkid 1337 --bootnodes $ETH_BOOT_NODE > $ETH_LOG_DIR/membernode.log 2>&1"
fi



exec /bin/sh -c "$CMD"
