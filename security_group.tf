/*
  Security Group Definitions
*/

/*
  Load Balancer Security group
*/
resource "aws_security_group" "concourse" {
    name = "${var.environment}-concourse"
    description = "Allow incoming connections for concourse."
    vpc_id = "${aws_vpc.PcfVpc.id}"
    tags {
        Name = "${var.environment}-concourse"
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 4443
        to_port = 4443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

/*
  Jumpbox Security group
*/
resource "aws_security_group" "jumpbox" {
    name = "${var.environment}-pcf_jumpbox_sg"
    description = "Allow incoming connections for Jumpbox."
    vpc_id = "${aws_vpc.PcfVpc.id}"
    tags {
        Name = "${var.environment}-JumpBox"
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 3128
        to_port = 3128
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "jumpbox2" {
    name = "${var.environment}-pcf_jumpbox_sg2"
    description = "Allow incoming connections for Jumpbox."
    vpc_id = "${aws_vpc.PcfVpc.id}"
    tags {
        Name = "${var.environment}-JumpBox2"
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "directorSG" {
    name = "${var.environment}-pcf_director_sg"
    description = "Allow incoming connections for Ops Manager."
    vpc_id = "${aws_vpc.PcfVpc.id}"
    tags {
        Name = "${var.environment}-Bosh Director Security Group"
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 25555
        to_port = 25555
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 8443
        to_port = 8443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 6868
        to_port = 6868
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${aws_subnet.PcfVpcPublicSubnet_az1.cidr_block}"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${aws_subnet.PcfVpcPrivateSubnet_az1.cidr_block}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

/*
  PCF VMS Security group
*/
resource "aws_security_group" "pcfSG" {
    name = "${var.environment}-pcf_vms_sg"
    description = "Allow connections between PCF VMs."
    vpc_id = "${aws_vpc.PcfVpc.id}"
    tags {
        Name = "${var.environment}-PCF VMs Security Group"
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${aws_subnet.PcfVpcPrivateSubnet_az1.cidr_block}"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "rdsSG" {
    name = "${var.environment}-pcf_rds_sg"
    description = "Allow incoming connections for RDS."
    vpc_id = "${aws_vpc.PcfVpc.id}"
    tags {
        Name = "${var.environment}-RDS Security Group"
    }
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

}
