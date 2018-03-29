import boto3
import argparse
import sys

def get_vpc_id():
    ec2 = boto3.client('ec2')
    cidr_block = "10.0.0.0/16"

    filters=[
        {
            'Name': 'cidr',
            'Values': [
                cidr_block,
            ]
        },
        {
            'Name': 'isDefault',
            'Values': [
                'false',
            ]
        },
    ]

    response = ec2.describe_vpcs(Filters=filters)

    if len(response['Vpcs']) != 1:
        print "Should return 1 VPC matching filter, found %d!" % (len(response['Vpcs']))
        sys.exit(1)

    return response['Vpcs'][0]['VpcId']

def get_nat_route_table(vpc_id):
    ec2 = boto3.resource('ec2')
    vpc = ec2.Vpc(vpc_id)
    route_table_iter = vpc.route_tables.all()
    for rt in route_table_iter:
        for t in rt.tags:
            if t['Key'] == 'Name' and t['Value'] == 'nat-table':
                return rt.id
    return None

def delete_route_table(rt_id):
    ec2 = boto3.resource('ec2')
    rt = ec2.RouteTable(rt_id)
    for rta in rt.associations:
        try:
            rta.delete()
        except:
            print "Error deleting route table association for %s" % rta
    try:
        rt.delete()
    except:
        print "Error deleting route table %s" % rt

def main():
    vpc_id = get_vpc_id()
    rt_id = get_nat_route_table(vpc_id)
    if rt_id is not None:
        delete_route_table(rt_id)
    else:
        print "Could not find a routing table to delete..."


if __name__ == '__main__':
    main()
