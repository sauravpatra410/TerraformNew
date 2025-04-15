resource "aws_instance" "new" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "MyEC2Instance"
  }
}
