provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "my_ec2" {
     ami = "ami-0ce45259f491c3d4f"
     instance_type = "t2.micro"

     tags = {
       Name = "Terraformimport"
     }
}