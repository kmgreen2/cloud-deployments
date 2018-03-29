variable "vpc_id" {
  description = "VPC id"
}
variable "azs" {
  description = "AZ names"
  type = "list"
}
variable "public_subnet_ids" {
  description = "Subnets ids that represent public-facing AWS-only networks"
  type = "list"
}
variable "private_subnet_ids" {
  description = "Subnet ids that represent hybrid AWS/private networks"
  type = "list"
}
variable "ami" {
  description = "AMI to deploy"
}
variable "default_security_group" {
  description = "Default SG for all instances"
}
variable "instance_type" {
  description = "Instance type to launch"
  default = "t2.micro"
}
variable "hosted_zone_id" {
  description = "Id of the default hosted zone for DNS"
}
variable "bastion_host_prefix" {
  description = "Prefix to use for bastion hostnames in DNS"
}
