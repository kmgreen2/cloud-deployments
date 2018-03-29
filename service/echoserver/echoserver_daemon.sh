#!/usr/bin/bash

function go_echoserver {
    python /service/echoserver/echo_server.py > /var/log/echoserver.log
}

# Write to PID file
mkdir -p /var/spool/echoserver/

go_echoserver &

echo $! > /var/spool/echoserver/master.pid
