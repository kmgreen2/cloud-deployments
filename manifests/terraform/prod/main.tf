data "aws_vpc" "k8svpc" {
  filter {
    name = "tag:Name"
    values = ["kmg-cluster.k8s.local"]
  }
}

data "aws_route_table" "k8srt" {
  filter {
    name = "tag:Name"
    values = ["kmg-cluster.k8s.local"]
  }
}

module "cloudvpc" {
  source = "../modules/vpc"

  aws_region = "us-west-2"
  cidr_block = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24"]
  public_subnets = ["10.0.2.0/24"]
  peer_vpc_id = "${data.aws_vpc.k8svpc.id}"
  peer_route_table_id = "${data.aws_route_table.k8srt.id}"
  azs = ["us-west-2a"]
}

module "privatevpc" {
  source = "../modules/vpc"

  aws_region = "us-west-2"
  cidr_block = "10.1.0.0/16"
  private_subnets = ["10.1.1.0/24"]
  public_subnets = ["10.1.2.0/24"]
  peer_vpc_id = "${module.cloudvpc.vpc_id}"
  peer_route_table_id = "${module.cloudvpc.route_table_private}"
  azs = ["us-west-2a"]
}

module "cloud-bastion" {
  source = "../modules/services/bastion"

  vpc_id = "${module.cloudvpc.vpc_id}"
  azs = "${module.cloudvpc.azs}"
  public_subnet_ids = "${module.cloudvpc.public_subnet_ids}"  
  private_subnet_ids = "${module.cloudvpc.private_subnet_ids}"  
  ami = "ami-293fa451"
  default_security_group = "${module.cloudvpc.default_sg_id}"
  instance_type = "t2.micro"
  # Needed to setup DNS records for bastion
  hosted_zone_id = "Z1IVELDM86BQAN" 
  bastion_host_prefix = "cloud-bastion"
}

module "private-bastion" {
  source = "../modules/services/bastion"

  vpc_id = "${module.privatevpc.vpc_id}"
  azs = "${module.privatevpc.azs}"
  public_subnet_ids = "${module.privatevpc.public_subnet_ids}"  
  private_subnet_ids = "${module.privatevpc.private_subnet_ids}"  
  ami = "ami-293fa451"
  default_security_group = "${module.privatevpc.default_sg_id}"
  instance_type = "t2.micro"
  # Needed to setup DNS records for bastion
  hosted_zone_id = "Z1IVELDM86BQAN" 
  bastion_host_prefix = "private-bastion"
}


module "dumbstack" {
  source = "../modules/services/dumbstack"

  count = 1
  azs = "${module.cloudvpc.azs}"
  vpc_id = "${module.cloudvpc.vpc_id}"
  public_subnets = "${module.cloudvpc.public_subnets}"  
  public_subnet_ids = "${module.cloudvpc.public_subnet_ids}"  
  private_subnet_ids = "${module.cloudvpc.private_subnet_ids}"  
  private_subnets = "${module.cloudvpc.private_subnets}"  
  ami = "ami-523da62a"
  default_security_group = "${module.cloudvpc.default_sg_id}"
  instance_type = "t2.micro"
  bastion_host = "${module.cloud-bastion.bootstrap_host}"
}

module "echoserver-public" {
  source = "../modules/services/echoserver"

  vpc_id = "${module.cloudvpc.vpc_id}"
  azs = "${module.cloudvpc.azs}"
  count = 2
  name = "echoserver-public"
  subnet_ids = "${module.cloudvpc.public_subnet_ids}"
  subnets = "${module.cloudvpc.public_subnets}"
  ami = "ami-8f3da6f7"
  default_security_group = "${module.cloudvpc.default_sg_id}"
  instance_type = "t2.micro"
  bastion_host = "${module.cloud-bastion.bootstrap_host}"
  create_lb = 1
  internal_lb = "false"
  lb_subnet_ids = "${module.cloudvpc.public_subnet_ids}"
  access_log_bucket = "private-access-logs"
  # Needed to setup DNS records for echoserver
  hosted_zone_id = "Z1IVELDM86BQAN" 
}

module "echoserver-private" {
  source = "../modules/services/echoserver"

  vpc_id = "${module.cloudvpc.vpc_id}"
  azs = "${module.cloudvpc.azs}"
  count = 2
  name = "echoserver-private"
  subnet_ids = "${module.cloudvpc.private_subnet_ids}"
  subnets = "${module.cloudvpc.private_subnets}"
  ami = "ami-8f3da6f7"
  default_security_group = "${module.cloudvpc.default_sg_id}"
  instance_type = "t2.micro"
  bastion_host = "${module.cloud-bastion.bootstrap_host}"
  create_lb = 0
  internal_lb = "true"
  lb_subnet_ids = "${module.cloudvpc.public_subnet_ids}"
  access_log_bucket = "private-access-logs"
  # Needed to setup DNS records for echoserver
  hosted_zone_id = "Z1IVELDM86BQAN" 
}
