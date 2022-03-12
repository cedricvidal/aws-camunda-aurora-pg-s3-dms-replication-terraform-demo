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
