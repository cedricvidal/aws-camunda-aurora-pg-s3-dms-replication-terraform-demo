provider "aws" {
    region = "us-west-1"
}

resource "aws_instance" "demo-instance-1" {
    ami = "ami-01f87c43e618bf8f0" // Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
    instance_type = "t2.micro"
    key_name = "demo-key-1"
    tags = {
        "Name" = "demo-instance-1"
    }
}

resource "aws_vpc" "demo-vpc-1" {
    cidr_block           = "172.31.0.0/16"
    instance_tenancy     = "default"
    enable_dns_support   = "true"
    enable_dns_hostnames = "true"
    enable_classiclink   = "false"
    tags = {
        Name = "demo-vpc-1"
    }
}

resource "aws_subnet" "demo-subnet-public-1" {
    vpc_id = aws_vpc.demo-vpc-1.id
    cidr_block = "172.31.0.0/20"
    map_public_ip_on_launch = true
    availability_zone       = "us-west-1a"
    tags = {
        Name = "demo-subnet-public-1"
    }
}

resource "aws_subnet" "demo-subnet-public-2" {
    vpc_id = aws_vpc.demo-vpc-1.id
    cidr_block = "172.31.16.0/20"
    map_public_ip_on_launch = true
    availability_zone       = "us-west-1b"
    tags = {
        Name = "demo-subnet-public-2"
    }
}

# Creating Internet Gateway in AWS VPC
resource "aws_internet_gateway" "demo-gw-1" {
    vpc_id = aws_vpc.demo-vpc-1.id

    tags = {
        Name = "demo-gw-1"
    }
}

# Creating Route Tables for Internet gateway
resource "aws_route_table" "demo-rtb-public-1" {
    vpc_id = aws_vpc.demo-vpc-1.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo-gw-1.id
    }

    tags = {
        Name = "demo-rtb-public-1"
    }
}


# Creating Route Associations public subnets
resource "aws_route_table_association" "dev-public-1-a" {
    subnet_id      = aws_subnet.demo-subnet-public-1.id
    route_table_id = aws_route_table.demo-rtb-public-1.id
}

resource "aws_route_table_association" "dev-public-2-a" {
    subnet_id      = aws_subnet.demo-subnet-public-2.id
    route_table_id = aws_route_table.demo-rtb-public-1.id
}
