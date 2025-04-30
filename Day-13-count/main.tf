provider "aws" {
  region = "us-west-1"
}
variable "env" {
  type = list(string)
  default = [ "dev", "test", "prod" ]
}
resource "aws_instance" "name" {
  ami = "ami-0ce45259f491c3d4f"
  instance_type = "t2.micro"
  availability_zone = "us-west-1a"
  count = length(var.env)

  tags = {
    Name = var.env[count.index]
  }
}