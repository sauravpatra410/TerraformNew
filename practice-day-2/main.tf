resource "aws_instance" "new" {
  ami           = "ami-00a929b66ed6e0de6"
  instance_type = "t2.micro"

  tags = {
    Name = "updatedInstance"
  }
}
