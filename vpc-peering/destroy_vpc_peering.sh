set -ex

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_KEY}
export AWS_DEFAULT_REGION=${AWS_REGION}
export AWS_DEFAULT_OUTPUT=json

PEER_VPC_ID=$(cat peering.tfstate | jq -r '.modules[0].resources["aws_vpc.PcfVpc"].primary.id')
REQUEST_VPC_ID=$(cat request.tfstate | jq -r '.modules[0].resources["aws_vpc.PcfVpc"].primary.id')

peer_route_table=$(cat peering.tfstate | jq -r '.modules[0].resources["aws_route_table.PrivateSubnetRouteTable_az1"].primary.attributes.id')
request_route_table=$(cat request.tfstate | jq -r '.modules[0].resources["aws_route_table.PublicSubnetRouteTable"].primary.attributes.id')


peering_subnet_cidr=$(cat peering.tfstate | jq -r '.modules[0].resources["aws_subnet.PcfVpcPrivateSubnet_az1"].primary.attributes.cidr_block')
request_subnet_cidr=$(cat request.tfstate | jq -r '.modules[0].resources["aws_subnet.PcfVpcPublicSubnet_az1"].primary.attributes.cidr_block')
peer_group_id=$(cat peering.tfstate | jq -r '.modules[0].resources["aws_security_group.directorSG"].primary.attributes.id')
request_group_id=$(cat request.tfstate | jq -r '.modules[0].resources["aws_security_group.directorSG"].primary.attributes.id')

peering_id=$(aws ec2 describe-vpc-peering-connections --filters Name=requester-vpc-info.vpc-id,Values=${REQUEST_VPC_ID} | jq -r .VpcPeeringConnections[0].VpcPeeringConnectionId)

aws ec2 delete-route --route-table-id ${request_route_table} --destination-cidr-block ${peering_subnet_cidr}
aws ec2 revoke-security-group-ingress --group-id ${request_group_id} --protocol all --port 0-65535 --cidr ${peering_subnet_cidr}

aws ec2 delete-route --route-table-id ${peer_route_table} --destination-cidr-block ${request_subnet_cidr}
aws ec2 revoke-security-group-ingress --group-id ${peer_group_id} --protocol all --port 0-65535 --cidr ${request_subnet_cidr}
aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id=${peering_id}
