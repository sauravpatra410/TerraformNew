provider "aws" {
  region = "us-west-1"
}

data "aws_ami" "amzlinux" {
  most_recent = true
  owners = ["self"]

 filter {
   name = "name"
   values = ["ami-data-source"]
 }
}

data "aws_subnet" "custSubnet" {
  filter {
    name = "tag:Name"
    values = ["subnet-data-source"]
  }
}

resource "aws_instance" "name" {
  ami = data.aws_ami.amzlinux.id
  instance_type = "t2.micro"
  subnet_id = data.aws_subnet.custSubnet.id
}