module "ec2module" {
  source = "../Day-8-source-template"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  vpc_cidr      = var.vpc_cidr

}

