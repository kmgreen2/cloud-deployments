#!/bin/bash

sed -i "s/VAR_INSTANCENAME/${HOSTNAME}/" app.json

pm2 --no-daemon start app.json > /var/log/ethereum/ethnet_agent.log
