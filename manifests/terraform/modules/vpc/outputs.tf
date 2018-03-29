output "vpc_id" {
    value = "${aws_vpc.thisvpc.id}"
}
output "azs" {
    value = "${var.azs}"
}
output "public_subnet_ids" {
    value = ["${aws_subnet.public.*.id}"]
}
output "private_subnet_ids" {
    value = ["${aws_subnet.private.*.id}"]
}
output "public_subnets" {
    value = "${var.public_subnets}"
}
output "private_subnets" {
    value = "${var.private_subnets}"
}
output "default_sg_id" {
    value = "${aws_security_group.default.id}"
}
output "route_table_private" {
    value = "${aws_route_table.private.id}"
}
