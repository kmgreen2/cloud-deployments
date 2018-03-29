cp /etc/sysconfig/network /etc/sysconfig/network.orig
cp /tmp/network /etc/sysconfig/network
cp /tmp/ifcfg-eth* /etc/sysconfig/network-scripts
cp /tmp/route-eth* /etc/sysconfig/network-scripts
cp /tmp/rule-eth* /etc/sysconfig/network-scripts
