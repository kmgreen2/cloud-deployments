import boto3
import argparse
import sys

class ServiceProxy:
    def __init__(self, line):
        line_ary = line.split()
        self.tag = line_ary[0]
        self.fe_name = line_ary[1]
        self.fe_port = int(line_ary[2])
        self.be_port = int(line_ary[3])
        self.fe_iface = line_ary[4]
        self.be_ips = []

    def add_be_ip(self, ip):
        self.be_ips.append(ip)

    def to_haproxy_lines(self):
        str = ''
    
        str += 'frontend %s\n' % self.fe_name
        #str += '\tbind *:%d interface %s\n' % (self.fe_port, self.fe_iface)
        str += '\tbind 0.0.0.0:%d\n' % (self.fe_port)
        str += '\tmode tcp\n'
        str += '\tdefault_backend %s\n\n' % self.tag

        str += 'backend %s\n' % self.tag
        str += '\tmode tcp\n'
        str += '\tbalance roundrobin\n'
        str += '\toption tcp-check\n'
        str += '\ttcp-check send PING\n'
        for be_ip in self.be_ips:
            str += '\tserver %s %s:%d check\n' % (be_ip.replace('.', '_'), be_ip, self.be_port) 
        return str

    def __str__(self):
        return "tag: %s, FE: %s, FE-port: %d, BE-IP: %s, BE-port: %d\n" % (self.tag, self.fe_name, self.fe_port, self.be_ips, self.be_port)

def parse_args():
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('--config', dest='config', help='location of the config file')

    args = parser.parse_args()

    return args.config

def get_service_proxies(config):
    line_num = 1
    config_fp = open(config)
    service_proxies = {}
    while 1:
        line = config_fp.readline()
        if line == '':
            break
        line = line.strip()

        try:
            sp = ServiceProxy(line)
        except:
            print "Malformed entry at line %d:\n %s\n" % (line_num, line)
            sys.exit(1)

        if service_proxies.has_key(sp.tag):
            print "Warn: Duplicate tag: %s\n" % (sp.tag)
        else:
            service_proxies[sp.tag] = sp
        line_num += 1
    return service_proxies

def configure_backends(service_proxies):
    ec2 = boto3.client('ec2')
    response = ec2.describe_instances()

    for sp in service_proxies.values():
        ip = set_ips(response, sp)

def set_ips(response, service_proxy):
    tag_to_match = service_proxy.tag
    reservations = response['Reservations']
    for r in reservations:
        instances = r['Instances']
        for i in instances:
            if i['State']['Name'] != 'running':
                continue
            tags = i['Tags']
            for t in tags:
                if t['Key'] == 'haproxy-tag' and t['Value'] == tag_to_match:
                    service_proxy.add_be_ip(i['PrivateIpAddress'])
            
def main():
    config = parse_args()
    service_proxies = get_service_proxies(config)
    configure_backends(service_proxies)

    for sp in service_proxies.values():
        print sp.to_haproxy_lines()

if __name__ == '__main__':
    main()

