# subnet associations for public subnet
resource "aws_route_table_association" "a_az1" {
    subnet_id = "${aws_subnet.PcfVpcPublicSubnet_az1.id}"
    route_table_id = "${aws_route_table.PublicSubnetRouteTable.id}"
}

# subnet associations for infrastructure subnet

resource "aws_route_table_association" "i_az1" {
    subnet_id = "${aws_subnet.PcfVpcInfraSubnet_az1.id}"
    route_table_id = "${aws_route_table.PrivateSubnetRouteTable_az1.id}"
}

resource "aws_route_table_association" "private_az1" {
    subnet_id = "${aws_subnet.PcfVpcPrivateSubnet_az1.id}"
    route_table_id = "${aws_route_table.PrivateSubnetRouteTable_az1.id}"
}

resource "aws_route_table_association" "rds_az1" {
    subnet_id = "${aws_subnet.PcfVpcRdsSubnet_az1.id}"
    route_table_id = "${aws_route_table.PrivateSubnetRouteTable_az1.id}"
}

resource "aws_route_table_association" "rds_az2" {
    subnet_id = "${aws_subnet.PcfVpcRdsSubnet_az2.id}"
    route_table_id = "${aws_route_table.PrivateSubnetRouteTable_az2.id}"
}
