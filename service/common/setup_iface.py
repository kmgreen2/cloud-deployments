import sys
import argparse
import boto3
import os

#
# If you are using a non-AWS version of Linux and want multiple network interfaces,
# you must configure them manually.  This script will configure an additional device
#
# This should be run as a cloud-init script
#

def parse_args():
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('-i', dest='index', type=int, required=True, help='index of the interface to configure')
    parser.add_argument('-I', dest='iface', required=True, help='Id of the ENI')
    parser.add_argument('-v', dest='vpcid', required=True, help='Id of the VPC')

    args = parser.parse_args()
    return args

def update_gateway_device():
    os.system("cp /etc/sysconfig/network /tmp/network")
    with open("/tmp/network", "a") as netcfg:
        netcfg.write("GATEWAYDEV=eth0\n")

def create_ifcfg(index, macaddr):
    with open("/tmp/ifcfg-eth%d" % (index), "w") as ifcfg:
        ifcfg.write("BOOTPROTO=dhcp\nDEVICE=eth%d\nHWADDR=%s\nONBOOT=yes\nTYPE=Ethernet\nUSERCTL=no" % (index, macaddr))

def create_route(index, ipaddr, subnet, gateway):
    with open("/tmp/route-eth%d" % (index), "w") as routecfg:
        routecfg.write("default via %s dev eth%d table %d\n" % (gateway, index, index+1))
        routecfg.write("%s dev eth%d src %s table %d\n" % (subnet, index, ipaddr, index+1))

def create_rule(index, ipaddr):
    with open("/tmp/rule-eth%d" % (index), "w") as rulecfg:
        rulecfg.write("from %s/32 table %d" % (ipaddr, index+1))

def main():
    args = parse_args()
    print("Creating /tmp/network...")
    update_gateway_device()

    if args.index == 0:
        print("Cannot modify configuration for eth0!\n")
        sys.exit(2)
    
    ec2 = boto3.resource('ec2')
    try:
        eni = ec2.NetworkInterface(args.iface)
        vpc = ec2.Vpc(args.vpcid)

        macaddr = eni.mac_address
        ipaddr = eni.private_ip_address
        subnet = eni.subnet.cidr_block
        vpc_cidr = vpc.cidr_block
        vpc_network = vpc_cidr.split('/')[0]
        gateway = ".".join(str(x) for x in vpc_network.split('.')[:3] + ['1'])
    except:
        print("Error getting ENI info for: %s\n" % args.iface)
        sys.exit(1)

    print("Creating /tmp/ifcfg-eth%d..." % (args.index))
    create_ifcfg(args.index, macaddr)
    print("Creating /tmp/route-eth%d..." % (args.index))
    create_route(args.index, ipaddr, subnet, gateway)
    print("Creating /tmp/rule-eth%d..." % (args.index))
    create_rule(args.index, ipaddr)

if __name__ == '__main__':
    main()
