variable "env" {
  type = list(string)
  default = [ "dev", "test", "prod" ]
}

variable "ami_id" {
  type = string
  default = "ami-0ce45259f491c3d4f"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}