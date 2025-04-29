provider "aws" {
  region = "us-west-1"
}

resource "aws_key_pair" "example" {
  key_name   = "newkey1"  # Replace with your desired key name
  public_key = file("C:/Users/sweta/.ssh/id_ed25519.pub")
}


resource "aws_iam_policy" "s3_access_policy" {
  name        = "EC2S3AccessPolicy"
  description = "Policy for EC2 instances to access S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::newmeyyanbucket",
          "arn:aws:s3:::newmeyyanbucket/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role" "ec2_role" {
  name = "ec2_s3_access_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}


resource "aws_iam_role_policy_attachment" "ec2_role_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}


resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_s3_access_instance_profile"
  role = aws_iam_role.ec2_role.name
}


resource "aws_instance" "web_server" {
  ami                  = "ami-0ce45259f491c3d4f" 
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.example.key_name   
  security_groups      = ["default"]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  availability_zone    = "us-west-1a"

  tags = {
    Name = "MyWebServer"
  }
}


resource "null_resource" "setup_and_upload" {
  depends_on = [aws_instance.web_server]

  provisioner "remote-exec" {
    inline = [
      
      "sudo yum update -y",
      "sudo yum install -y httpd",

      
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "sudo mkdir -p /var/www/html",
      
      "echo '<h1>Welcome to My Web Server</h1>' | sudo tee /var/www/html/index.html",
      "sudo yum install -y awscli",
      
      "aws s3 cp /var/www/html/index.html s3://newmeyyanbucket/",
      "echo 'File uploaded to S3'"
  
      
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user" 
    private_key = file("C:/Users/sweta/.ssh/id_ed25519")
    host        = aws_instance.web_server.public_ip
  }

  triggers = {
    instance_id = aws_instance.web_server.id
  }
}
