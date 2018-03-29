variable "aws_region" {
  description = "AWS region to launch servers."
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type = "list"
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type = "list"
}

variable "cidr_block" {
  description = "CIDR block for this VPC"
}

variable "azs" {
  description = "A list of availability zones in the region"
  type = "list"
}

variable "peer_vpc_id" {
  description = "List of VPCs to setup peering with"
}

variable "peer_route_table_id" {
  description = "This will be assigned via an interpolation of a resource(s) to ensure it is not created before the resource(s)"
}
