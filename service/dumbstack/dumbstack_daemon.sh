#!/usr/bin/bash

function go_dumbstack {
    while (( 1 )); do
        su -c 'python /service/dumbstack/dumbstack_configure.py --config /service/dumbstack/dumbstack.cfg' centos > /tmp/additional_haproxy.cfg
        if [[ $? == "0" ]]; then
            cat /etc/haproxy/haproxy.cfg.orig /tmp/additional_haproxy.cfg > /tmp/haproxy.cfg
        fi
        diff /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg
        if [[ $? == "0" ]]; then
            echo "No changes, not reconfiguring..."
        else
            echo "Detected changes, reconfiguring..."
            diff /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg
            sudo mv /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg
            sudo service haproxy reload
        fi
        sleep 30
    done
}

# Write to PID file
mkdir -p /var/spool/dumbstack/

go_dumbstack &

echo $! > /var/spool/dumbstack/master.pid
