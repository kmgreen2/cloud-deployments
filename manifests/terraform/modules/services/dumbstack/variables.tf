variable "vpc_id" {
  description = "VPC id"
}
variable "public_subnet_ids" {
  description = "Subnets ids that represent publically accessible networks"
  type = "list"
}
variable "private_subnet_ids" {
  description = "Subnet ids that represent private networks"
  type = "list"
}
variable "public_subnets" {
  description = "Subnets that represent public networks"
  type = "list"
}
variable "private_subnets" {
  description = "Subnets that represent private networks"
  type = "list"
}
variable "count" {
  description = "Number of instances to deploy"
}
variable "ami" {
  description = "AMI to deploy"
}
variable "default_security_group" {
  description = "Default security group to associate with all instances"
}
variable "instance_type" {
  description = "Instance type to launch"
  default = "t2.micro"
}
variable "bastion_host" {
  description = "Bastion host to proxy connections through"
}
variable "azs" {
  description = "Availability Zones available for use"
}
