resource "aws_elb" "concourse" {
  name = "concourse"
  subnets = ["${aws_subnet.PcfVpcPublicSubnet_az1.id}"]
  security_groups = ["${aws_security_group.concourse.id}"]

  listener {
    instance_port = 80
    instance_protocol = "HTTP"
    lb_port = 443
    lb_protocol = "HTTPS"
    ssl_certificate_id = "${var.aws_cert_arn}"
  }
  listener {
    instance_port = 80
    instance_protocol = "TCP"
    lb_port = 4443
    lb_protocol = "SSL"
    ssl_certificate_id = "${var.aws_cert_arn}"
  }
  listener {
    instance_port = 80
    instance_protocol = "TCP"
    lb_port = 80
    lb_protocol = "TCP"
  }
  health_check {
    target = "TCP:80"
    timeout = 5
    interval = 30
    unhealthy_threshold = 2
    healthy_threshold = 10
  }
  tags {
    Name = "${var.environment}-concourse-Elb"
  }
}
