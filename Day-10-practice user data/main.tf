resource "aws_instance" "myec2" {
  ami           = "ami-0ce45259f491c3d4f"
  instance_type = "t2.micro"

  user_data = file("userdata.sh")

  tags = {
    Name = "EC2WithUserData"
  }
}