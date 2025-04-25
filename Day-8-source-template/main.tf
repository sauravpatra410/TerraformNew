resource "aws_instance" "name" {
  ami = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "ModularEC2"
  }
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "ModularVPC"
  }
}