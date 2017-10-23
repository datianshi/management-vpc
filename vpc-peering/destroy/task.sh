#!/bin/bash

set -e

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_KEY}
export AWS_DEFAULT_REGION=${AWS_REGION}
export AWS_DEFAULT_OUTPUT=json

PEERING_TFSTATE="peering-terraform-state/peering-terraform.tfstate"
REQUEST_TFSTATE="terraform-state/terraform.tfstate"

REQUEST_VPC_ID=$(cat ${REQUEST_TFSTATE} | jq -r '.modules[0].resources["aws_vpc.PcfVpc"].primary.id')

peering_id=$(aws ec2 describe-vpc-peering-connections --filters Name=requester-vpc-info.vpc-id,Values=${REQUEST_VPC_ID} | jq -r .VpcPeeringConnections[0].VpcPeeringConnectionId)
STATUS=$(aws ec2 describe-vpc-peering-connections --filters Name=requester-vpc-info.vpc-id,Values=${REQUEST_VPC_ID} | jq -r .VpcPeeringConnections[0].Status.Code)

if [[ ("${peering_id}X" != "X") && ("${STATUS}" != "deleted") ]]
then
  aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id=${peering_id}
  peer_route_table=$(cat ${PEERING_TFSTATE} | jq -r '.modules[0].resources["aws_route_table.PrivateSubnetRouteTable_az1"].primary.attributes.id')
  request_route_table=$(cat ${REQUEST_TFSTATE} | jq -r '.modules[0].resources["aws_route_table.PublicSubnetRouteTable"].primary.attributes.id')
  peering_subnet_cidr=$(cat ${PEERING_TFSTATE} | jq -r '.modules[0].resources["aws_subnet.PcfVpcPrivateSubnet_az1"].primary.attributes.cidr_block')
  request_subnet_cidr=$(cat ${REQUEST_TFSTATE} | jq -r '.modules[0].resources["aws_subnet.PcfVpcPublicSubnet_az1"].primary.attributes.cidr_block')
  peer_group_id=$(cat ${PEERING_TFSTATE} | jq -r '.modules[0].resources["aws_security_group.directorSG"].primary.attributes.id')
  request_group_id=$(cat ${REQUEST_TFSTATE} | jq -r '.modules[0].resources["aws_security_group.directorSG"].primary.attributes.id')

  aws ec2 delete-route --route-table-id ${request_route_table} --destination-cidr-block ${peering_subnet_cidr}
  aws ec2 revoke-security-group-ingress --group-id ${request_group_id} --protocol all --port 0-65535 --cidr ${peering_subnet_cidr}
  aws ec2 delete-route --route-table-id ${peer_route_table} --destination-cidr-block ${request_subnet_cidr}
  aws ec2 revoke-security-group-ingress --group-id ${peer_group_id} --protocol all --port 0-65535 --cidr ${request_subnet_cidr}
fi
