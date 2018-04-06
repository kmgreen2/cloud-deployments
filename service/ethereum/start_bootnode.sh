#!/bin/bash
  
set -e

if [[ -n $ETH_DEBUG ]]; then
    DLV="dlv --headless=true --listen=:$ETH_DEBUG_PORT --log --api-version=2 exec"
    CMD=$DLV" bootnode -- --verbosity 6 --nodekey=$ETH_DATA_DIR/boot.key > $ETH_LOG_DIR/bootnode.log 2>&1"
else
    CMD="bootnode --verbosity 6 --nodekey=$ETH_DATA_DIR/boot.key > $ETH_LOG_DIR/bootnode.log 2>&1"
fi

echo "changeme" > $ETH_DATA_DIR/.boot.pwd
export ETHERBASE="2dbeb96b6fdf54834b3c33cd50e1349ac7bef7c6"

# Create genesis block
geth --datadir="$ETH_DATA_DIR" init $ETH_DATA_DIR/genesis.json

exec sh -c "$CMD"
