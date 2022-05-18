data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block
    tags = {
        Name = "${var.prefix}-vpc"
    }
}

resource "aws_subnet" "subnets" {
    count = var.zones_quantity
    availability_zone = data.aws_availability_zones.available.names[count.index]
    vpc_id = resource.aws_vpc.vpc.id
    map_public_ip_on_launch = true
    cidr_block = var.subnet_cidr_blocks[count.index]
    tags = {
        Name = "${var.prefix}-subnet-${count.index+1}"
    }
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "${var.prefix}-internet-gateway"
    }
}

resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
    tags = {
        Name = "${var.prefix}-route-table"
    }
}

resource "aws_route_table_association" "route_table_association" {
    count = var.zones_quantity
    route_table_id = aws_route_table.route_table.id
    subnet_id = aws_subnet.subnets.*.id[count.index]
}