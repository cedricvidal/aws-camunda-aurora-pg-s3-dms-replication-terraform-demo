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

resource "aws_subnet" "demo-subnet-public-1" {
    vpc_id = "vpc-07c275b9477368a53"
    cidr_block = "172.31.0.0/20"
    map_public_ip_on_launch = true
    availability_zone       = "us-west-1a"
    tags = {
        Name = "demo-subnet-public-1"
    }
}

resource "aws_subnet" "demo-subnet-public-2" {
    vpc_id = "vpc-07c275b9477368a53"
    cidr_block = "172.31.16.0/20"
    map_public_ip_on_launch = true
    availability_zone       = "us-west-1b"
    tags = {
        Name = "demo-subnet-public-2"
    }
}
