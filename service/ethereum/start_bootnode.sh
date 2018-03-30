#!/bin/bash
  
set -e

if [[ -n $ETH_DEBUG ]]; then
    DLV="dlv --headless=true --listen=:$ETH_DEBUG_PORT --log --api-version=2 exec"
    CMD=$DLV" bootnode -- --verbosity 6 --nodekey=$ETH_DATA_DIR/boot.key > $ETH_LOG_DIR/bootnode.log 2>&1"
else
    CMD="bootnode --verbosity 6 --nodekey=$ETH_DATA_DIR/boot.key > $ETH_LOG_DIR/bootnode.log 2>&1"
fi

exec sh -c "$CMD"
