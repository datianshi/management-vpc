#!/bin/bash

set -e

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_KEY}
export AWS_DEFAULT_REGION=${AWS_REGION}
export AWS_DEFAULT_OUTPUT=json

REQUEST_TFSTATE="terraform-state/terraform.tfstate"

REQUEST_VPC_ID=$(cat ${REQUEST_TFSTATE} | jq -r '.modules[0].resources["aws_vpc.PcfVpc"].primary.id')
peering_id=$(aws ec2 describe-vpc-peering-connections --filters Name=requester-vpc-info.vpc-id,Values=${REQUEST_VPC_ID} | jq -r .VpcPeeringConnections[0].VpcPeeringConnectionId)
aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id=${peering_id}
