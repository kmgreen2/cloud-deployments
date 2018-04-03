#!/bin/bash

export WS_SECRET="changeme"

npm start > /var/log/ethereum/ethstats.log 2>&1
