#!/bin/bash

set -e

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_KEY}
export AWS_DEFAULT_REGION=${AWS_REGION}
export AWS_DEFAULT_OUTPUT=json

PEERING_TFSTATE="peering-terraform-state/peering-terraform.tfstate"
REQUEST_TFSTATE="terraform-state/terraform.tfstate"

PEER_VPC_ID=$(cat ${PEERING_TFSTATE} | jq -r '.modules[0].resources["aws_vpc.PcfVpc"].primary.id')
REQUEST_VPC_ID=$(cat ${REQUEST_TFSTATE} | jq -r '.modules[0].resources["aws_vpc.PcfVpc"].primary.id')

peer_route_table=$(cat ${PEERING_TFSTATE} | jq -r '.modules[0].resources["aws_route_table.PrivateSubnetRouteTable_az1"].primary.attributes.id')
request_route_table=$(cat ${REQUEST_TFSTATE} | jq -r '.modules[0].resources["aws_route_table.PublicSubnetRouteTable"].primary.attributes.id')
request_private_route_table_az1=$(cat request.tfstate | jq -r '.modules[0].resources["aws_route_table.PrivateSubnetRouteTable_az1"].primary.attributes.id')
request_private_route_table_az2=$(cat request.tfstate | jq -r '.modules[0].resources["aws_route_table.SubnetRouteTable_az2"].primary.attributes.id')
request_private_route_table_az3=$(cat request.tfstate | jq -r '.modules[0].resources["aws_route_table.SubnetRouteTable_az3"].primary.attributes.id')


peering_id=$(aws --output=json ec2 create-vpc-peering-connection --vpc-id ${REQUEST_VPC_ID} --peer-vpc-id ${PEER_VPC_ID} | jq -r .VpcPeeringConnection.VpcPeeringConnectionId)
peering_subnet_cidr=$(cat peering.tfstate | jq -r '.modules[0].resources["aws_vpc.PcfVpc"].primary.attributes.cidr_block')
request_subnet_cidr=$(cat request.tfstate | jq -r '.modules[0].resources["aws_vpc.PcfVpc"].primary.attributes.cidr_block')
peer_group_id=$(cat ${PEERING_TFSTATE} | jq -r '.modules[0].resources["aws_security_group.directorSG"].primary.attributes.id')
request_director_group_id=$(cat ${REQUEST_TFSTATE} | jq -r '.modules[0].resources["aws_security_group.directorSG"].primary.attributes.id')
request_vm_group_id=$(cat ${REQUEST_TFSTATE} | jq -r '.modules[0].resources["aws_security_group.pcfSG"].primary.attributes.id')

aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id ${peering_id}

aws ec2 create-route --route-table-id ${request_route_table} --destination-cidr-block ${peering_subnet_cidr} --vpc-peering-connection-id ${peering_id}
aws ec2 create-route --route-table-id ${request_private_route_table_az1} --destination-cidr-block ${peering_subnet_cidr} --vpc-peering-connection-id ${peering_id}
aws ec2 create-route --route-table-id ${request_private_route_table_az2} --destination-cidr-block ${peering_subnet_cidr} --vpc-peering-connection-id ${peering_id}
aws ec2 create-route --route-table-id ${request_private_route_table_az3} --destination-cidr-block ${peering_subnet_cidr} --vpc-peering-connection-id ${peering_id}
aws ec2 authorize-security-group-ingress --group-id ${request_director_group_id} --protocol all --port 0-65535 --cidr ${peering_subnet_cidr}
aws ec2 authorize-security-group-ingress --group-id ${request_vm_group_id} --protocol all --port 0-65535 --cidr ${peering_subnet_cidr}

aws ec2 create-route --route-table-id ${peer_route_table} --destination-cidr-block ${request_subnet_cidr} --vpc-peering-connection-id ${peering_id}
aws ec2 authorize-security-group-ingress --group-id ${peer_group_id} --protocol all --port 0-65535 --cidr ${request_subnet_cidr}
