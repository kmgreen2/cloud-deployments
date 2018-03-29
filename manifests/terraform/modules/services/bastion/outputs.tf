output "bootstrap_host" {
    value = "${element(aws_instance.bastion.*.public_dns, 0)}"
}
