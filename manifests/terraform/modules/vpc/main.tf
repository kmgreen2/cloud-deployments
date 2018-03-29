# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "thisvpc" {
  cidr_block = "${var.cidr_block}"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.thisvpc.id}"
}

# Create public subnets to launch our instances into
resource "aws_subnet" "public" {
  count = "${length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  vpc_id                  = "${aws_vpc.thisvpc.id}"
  cidr_block              = "${var.public_subnets[count.index]}"
  availability_zone       = "${element(var.azs, count.index)}"
}

# Create private subnets to launch our instances into
resource "aws_subnet" "private" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  vpc_id                  = "${aws_vpc.thisvpc.id}"
  cidr_block              = "${var.private_subnets[count.index]}"
  availability_zone       = "${element(var.azs, count.index)}"
}

# Our default security group to access
# the instances over SSH, the AWS API and ping
resource "aws_security_group" "default" {
  name        = "default group"
  vpc_id      = "${aws_vpc.thisvpc.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_peering_connection" "vpc_peering" {
  peer_vpc_id = "${var.peer_vpc_id}"
  vpc_id = "${aws_vpc.thisvpc.id}"

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  auto_accept = true
}

data "aws_vpc" "peer_vpc" {
  id = "${var.peer_vpc_id}"
}

# Setup a NAT for services needing to talk to the internet
resource "aws_eip" "nat" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat" {

  allocation_id = "${aws_eip.nat.id}"
  # The NAT resides in the first public subnet
  subnet_id = "${aws_subnet.public.0.id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.thisvpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "private-table-${aws_vpc.thisvpc.id}"
  }
}

resource "aws_route_table_association" "a" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route" "this_to_peer" {
   route_table_id = "${var.peer_route_table_id}"
   destination_cidr_block = "${aws_vpc.thisvpc.cidr_block}"
   vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering.id}"
}

resource "aws_route" "peer_to_this" {
   route_table_id = "${aws_route_table.private.id}"
   destination_cidr_block = "${data.aws_vpc.peer_vpc.cidr_block}"
   vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering.id}"
}

# Send all non-VPC traffic to the IGW
resource "aws_route" "igw_route" {
  route_table_id = "${aws_vpc.thisvpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw.id}"
}
