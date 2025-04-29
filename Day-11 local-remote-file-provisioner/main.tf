provider "aws" {
  region = "us-west-1"
}

resource "aws_key_pair" "example" {
  key_name   = "newkey1"
  public_key = file("c:/Users/sweta/.ssh/id_ed25519.pub") 
}

resource "aws_instance" "example" {
  ami                         = "ami-04f7a54071e74f488"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.example.key_name 
  associate_public_ip_address = true


  provisioner "local-exec" {
    command = "echo Instance public IP is ${self.public_ip} > instance_info.txt"
  }

  
  provisioner "file" {
    source      = "app-config.json"
    destination = "/tmp/app-config.json"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("c:/Users/sweta/.ssh/id_ed25519") 
      host        = self.public_ip
    }
  }

  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install nginx -y",
      "cat /tmp/app-config.json", 
      "echo hello from terraform > remotefile100.txt"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("c:/Users/sweta/.ssh/id_ed25519") 
      host        = self.public_ip
    }
  }
}
