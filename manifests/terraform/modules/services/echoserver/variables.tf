variable "vpc_id" {
  description = "VPC id"
}
variable "subnet_ids" {
  description = "Subnets ids that represent networks for echoserver"
  type = "list"
}
variable "subnets" {
  description = "Subnets that represent networks for echoserver"
  type = "list"
}
variable "count" {
  description = "Number of instances to deploy"
}
variable "ami" {
  description = "AMI to deploy"
}
variable "name" {
  description = "A name used to name resources"
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
variable "create_lb" {
  description = "Set to 1 if you want to create an LB"
  default = 0
}
variable "internal_lb" {
  description = "Set to true if you want the LB to be internal"
  default = "true"
}
variable "lb_subnet_ids" {
  description = "Subnets to host the load balancer"
  type = "list"
}
variable "access_log_bucket" {
  description = "Bucket used to store access logs"
}
variable "azs" {
  description = "Availability Zones available for use"
  type = "list"
}
variable "hosted_zone_id" {
  description = "Id of the default hosted zone for DNS"
}
