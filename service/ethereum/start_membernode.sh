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

if [[ -n $ETH_DEBUG ]]; then
    DLV="dlv --headless=true --listen=:$ETH_DEBUG_PORT --log --api-version=2 exec"
fi

CMD=$DLV" geth -- --datadir="$ETH_DATA_DIR" -verbosity 6 --ipcdisable --port $ETH_PORT --rpcport $ETH_RPC_PORT --networkid 1337 --bootnodes $ETH_BOOT_NODE > $ETH_LOG_DIR/membernode.log 2>&1"


exec /bin/sh -c "$CMD"
