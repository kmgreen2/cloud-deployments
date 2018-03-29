resource "aws_security_group" "dumbstack" {
  name        = "dumbstack group"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an public ENI for each instance
resource "aws_network_interface" "public" {
  count = "${var.count}"
  subnet_id = "${var.public_subnet_ids[count.index % length(var.public_subnet_ids)]}"
  security_groups = ["${aws_security_group.dumbstack.id}", "${var.default_security_group}"]
  tags {
    Name = "public_network_interface"
  }
}   

# Create an private ENI for each instance
resource "aws_network_interface" "private" {
  count = "${var.count}"
  subnet_id = "${var.private_subnet_ids[count.index % length(var.private_subnet_ids)]}"
  security_groups = ["${aws_security_group.dumbstack.id}", "${var.default_security_group}"]
  tags {
    Name = "private_network_interface"
  }
}

# Dumbstack instance
resource "aws_instance" "dumbstack" { 
  count = "${var.count}" 
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"

  # Bring up the private interface first, since it is associated with a subnet that is linked
  # to the routing table that routes 0.0.0.0/0 to the NAT
  network_interface {
     network_interface_id = "${element(aws_network_interface.private.*.id, count.index)}"
     device_index = 0
  }
  network_interface {
     network_interface_id = "${element(aws_network_interface.public.*.id, count.index)}"
     device_index = 1
  }
  tags {
    Name = "dumbstack-${count.index}"
  }

  provisioner "remote-exec" {
    inline = ["python /service/common/setup_iface.py -i 1 -I ${element(aws_network_interface.public.*.id, count.index)} -v ${var.vpc_id}",
              "sudo /service/common/copy_iface.sh",
              "sudo service network restart",
              "sudo service haproxy start",
              "sudo service dumbstack start"]
    connection {
        type = "ssh"
        user = "centos"
        private_key = "${file("/root/.ssh/id_rsa_instance")}"
        bastion_private_key = "${file("/root/.ssh/id_rsa_instance")}"
        bastion_host = "${var.bastion_host}"
    }
  }
}
