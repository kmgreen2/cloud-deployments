#!/bin/bash
set -e

CMD="/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties"

if [[ $1 == "kafkaonly" ]]; then
    sed -i -r 's/zookeeper.connect=zookeeper:2181/zookeeper.connect=zk-0.zk.kafka.svc.cluster.local:2181/g' /opt/kafka/config/server.properties
else
    sed -i -r 's/zookeeper.connect=zookeeper:2181/zookeeper.connect=localhost:2181/g' /opt/kafka/config/server.properties
fi

exec $CMD
