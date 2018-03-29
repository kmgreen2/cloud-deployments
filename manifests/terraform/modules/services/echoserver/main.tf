resource "aws_security_group" "echoserver" {
  name        = "${var.name} group"
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

# Echoserver instance
resource "aws_instance" "echoserver" { 
  count = "${var.count}" 
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.subnet_ids[count.index % length(var.subnet_ids)]}"
  security_groups = ["${aws_security_group.echoserver.id}", "${var.default_security_group}"]

  tags {
    Name = "${var.name}-${count.index}"
    "haproxy-tag" = "${var.name}"
  }

  provisioner "remote-exec" {
    inline = ["sudo service echoserver start"]
    connection {
        type = "ssh"
        user = "centos"
        private_key = "${file("/root/.ssh/id_rsa_instance")}"
        bastion_private_key = "${file("/root/.ssh/id_rsa_instance")}"
        bastion_host = "${var.bastion_host}"
    }
  }
}

resource "aws_lb" "echoserver" {
  count = "${var.create_lb}"

  internal = "${var.internal_lb}"
  subnets = ["${var.lb_subnet_ids}"]

  load_balancer_type = "network"

  access_logs {
    bucket  = "${var.access_log_bucket}"
    prefix  = "echoserver-lb"
    enabled = true
  }

  tags {
    Name = "echoserver-lb"
  }
}

resource "aws_lb_target_group" "echoserver" {
  count = "${var.create_lb}"
  name     = "echoserver-target-group"
  port     = 1337
  protocol = "TCP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_lb_target_group_attachment" "echoserver" {
  count = "${var.create_lb > 0 ? length(var.count) : 0}"
  target_group_arn = "${aws_lb_target_group.echoserver.arn}"
  target_id = "${element(aws_instance.echoserver.*.id, count.index)}"
  port = "1337"
}

resource "aws_lb_listener" "echoserver" {
  count = "${var.create_lb}"
  load_balancer_arn = "${aws_lb.echoserver.arn}"
  port = "1337"
  protocol = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.echoserver.arn}"
    type             = "forward"
  }
}

resource "aws_route53_record" "bastion" {
  count = "${var.create_lb}"
  zone_id = "${var.hosted_zone_id}"
  name = "echoserver.kmgcloud.com"
  type = "CNAME"
  records = ["${element(aws_lb.echoserver.*.dns_name, count.index)}"]
  ttl = "60"
}

