provider "aws" {
  region = "us-west-1"
}


resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id
}


resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-west-1a"
}


resource "aws_subnet" "private_subnet1" {
  vpc_id     = aws_vpc.custom_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-1a"
}

resource "aws_subnet" "private_subnet2" {
  vpc_id     = aws_vpc.custom_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-1c"
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_eip" "nat_eip" {
  vpc = true
}


resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}


resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.custom_vpc.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_assoc1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rt.id
}



resource "aws_security_group" "open_sg" {
  name        = "allow_all"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_secretsmanager_secret" "db_secret1" {
  name = "db-credentials-new1"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret1.id
  secret_string = jsonencode({
    username = "admin"
    password = "admin123"
  })
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
}

resource "aws_db_instance" "rds" {
  identifier             = "mydbinstance"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "myapp"
  username               = jsondecode(aws_secretsmanager_secret_version.db_secret_version.secret_string)["username"]
  password               = jsondecode(aws_secretsmanager_secret_version.db_secret_version.secret_string)["password"]
  vpc_security_group_ids = [aws_security_group.open_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot    = true
}



resource "aws_instance" "ec2" {
  ami                    = "ami-04fc83311a8d478df"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.open_sg.id]
  key_name               = "newkey1" 
}


resource "aws_security_group" "secrets_endpoint_sg" {
  name        = "secrets-endpoint-sg"
  description = "SG for VPC endpoint"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id            = aws_vpc.custom_vpc.id
  service_name      = "com.amazonaws.us-west-1.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet1.id,aws_subnet.private_subnet2.id]
  security_group_ids = [aws_security_group.secrets_endpoint_sg.id]
  private_dns_enabled = true
}




resource "null_resource" "init_db" {
  depends_on = [aws_db_instance.rds, aws_instance.ec2]

  triggers = {
    always_run = timestamp()
  }

  provisioner "file" {
    source      = "init.sql"
    destination = "/tmp/init.sql"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("C:/Users/sweta/.ssh/id_ed25519")
      host        = aws_instance.ec2.public_ip
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("C:/Users/sweta/.ssh/id_ed25519")
      host        = aws_instance.ec2.public_ip
    }

    inline = [
      "sudo yum install -y mariadb105-server",
      "mysql -h ${aws_db_instance.rds.address} -u ${jsondecode(aws_secretsmanager_secret_version.db_secret_version.secret_string)["username"]} -p${jsondecode(aws_secretsmanager_secret_version.db_secret_version.secret_string)["password"]} < /tmp/init.sql"
    ]
  }
}
