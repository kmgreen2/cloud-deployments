# We create one bastion per AZ

# Create an public ENI for each bastion instance
resource "aws_network_interface" "bastion_public" {
  count = "${length(var.azs)}"
  subnet_id = "${var.public_subnet_ids[count.index]}"
  security_groups = ["${var.default_security_group}"]
  tags {
    Name = "public_network_interface"
  }
}

# Create an public ENI for each bastion instance
resource "aws_network_interface" "bastion_private" {
  count = "${length(var.azs)}"
  subnet_id = "${var.private_subnet_ids[count.index]}"
  security_groups = ["${var.default_security_group}"]
  tags {
    Name = "private_network_interface"
  }
}

resource "aws_eip" "bastion" {
  vpc = true
  count = "${length(var.azs)}"
  network_interface = "${element(aws_network_interface.bastion_public.*.id, count.index)}"
}

resource "aws_instance" "bastion" {
  count = "${length(var.azs)}"
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"

  network_interface {
     network_interface_id = "${element(aws_network_interface.bastion_public.*.id, count.index)}"
     device_index = 0
  }
  network_interface {
     network_interface_id = "${element(aws_network_interface.bastion_private.*.id, count.index)}"
     device_index = 1
  }
  tags {
    Name = "${var.bastion_host_prefix}-${count.index}"
  }

  provisioner "remote-exec" {
    inline = ["python /service/common/setup_iface.py -i 1 -I ${element(aws_network_interface.bastion_private.*.id, count.index)} -v ${var.vpc_id}",
              "sudo /service/common/copy_iface.sh",
              "sudo service network restart"]
    connection {
        type = "ssh"
        user = "centos"
        private_key = "${file("/root/.ssh/id_rsa_instance")}"
    }
  }
}

resource "aws_route53_record" "bastion" {
  count = "${length(var.azs)}"
  zone_id = "${var.hosted_zone_id}"
  name    = "${var.bastion_host_prefix}-${count.index}.kmgcloud.com"
  type    = "CNAME"
  records = ["${element(aws_instance.bastion.*.public_dns, count.index)}"]
  ttl     = "60"
}
