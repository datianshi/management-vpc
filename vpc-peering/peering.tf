variable main_cidr {}
variable peer_cidr {}
variable aws_access_key {}
variable aws_secret_key {}
variable peer_aws_access_key {}
variable peer_aws_secret_key {}
variable region {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

provider "aws" {
  alias = "peer"
  access_key = "${var.peer_aws_access_key}"
  secret_key = "${var.peer_aws_secret_key}"
  region = "${var.region}"
}

resource "aws_vpc" "main" {
  cidr_block = "${var.main_cidr}"
}

resource "aws_vpc" "peer" {
  provider   = "aws.peer"
  cidr_block = "${var.peer_cidr}"
}

data "aws_caller_identity" "peer" {
  provider = "aws.peer"
}

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = "${aws_vpc.main.id}"
  peer_vpc_id   = "${aws_vpc.peer.id}"
  peer_owner_id = "${data.aws_caller_identity.peer.account_id}"
  auto_accept   = false

  tags {
    Side = "Requester"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = "aws.peer"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer.id}"
  auto_accept               = true

  tags {
    Side = "Accepter"
  }
}
