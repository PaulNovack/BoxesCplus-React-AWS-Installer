terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


#Connect to instance (replace ip): ssh -i terraform_rsa ubuntu@3.84.165.241

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
    tags = {
      Name = "BoxesTerraformVPC"
    }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  depends_on = [
    aws_instance.mysql
  ]
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "terraform_key"
  vpc_security_group_ids = [aws_security_group.main.id]

  provisioner "file" {
    source      = "boxesCPlus.sh"
    destination = "/home/ubuntu/boxesCPlus.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/boxesCPlus.sh",
      "/home/ubuntu/boxesCPlus.sh args",
      "touch /home/ubuntu/mysqlIP.txt",
      "echo '${aws_instance.mysql.public_ip}' > mysqlIP.txt",
      "curl http://checkip.amazonaws.com > thisIP.txt",
    ]
  }



  tags = {
    Name = "Ubuntu MySQLCPPConnector Boxes Server"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("terraform_rsa")
    timeout     = "4m"
  }
}


resource "aws_instance" "mysql" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "terraform_key"
  vpc_security_group_ids = [aws_security_group.main.id]

  provisioner "file" {
    source      = "mysqlSetup.sh"
    destination = "/home/ubuntu/mysqlSetup.sh"
  }

    provisioner "file" {
      source      = "boxesCreate.sql"
      destination = "/home/ubuntu/boxesCreate.sql"
    }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/mysqlSetup.sh",
      "sudo su -c '/home/ubuntu/mysqlSetup.sh' root args"
    ]

  }

  tags = {
    Name = "Ubuntu MySQL"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("terraform_rsa")
    timeout     = "4m"
  }
}

locals {
  ports_in = [
    443,
    80,
    22,
    3306,
    33060
  ]
  ports_out = [
    0
  ]
}

resource "aws_security_group" "main" {

  tags = {
    Name = "Boxes VPC"
  }

  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  dynamic "ingress" {
    for_each = toset(local.ports_in)
    content {
      description = "Web and SSH Traffic from internet"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "terraform_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD8OBxSLEtZ/EZds4WbvdzAOq52fD3NE+ZjzYEWAkD2PgZuTyZ7b8XSyu+qwPxkeoC16a/KQvzpi/fvdGmw2Gyzt6fPvr9xcClDGjGt8L8ETYjsZi4KA2nAyB+1ruhiPTuXeht37B5dfbBwfo8YeYzo/ZgwXPirHsNMnOf43Axohg5O1qCSZ1NAiV5RarH8fS4BQE3LWI8tmxGJnHAfuiuGviwmrR9urYWyltAjDJ8ok2/T0/KDdHj8aUXyo1GNQzCbgB3nFTz0cPccmacyUArhlvVkHzwSsWo0ynI2xp4K8BNIz5CERaQX79jJyiE1ktMjZbPJmSeGgkIlYIz1I49P pnovack@pnovack-Inspiron-7706-2n1"
}



output "ec2_mysql_ip" {
  value = aws_instance.mysql.*.public_ip
}
output "ec2_web_ip" {
  value = aws_instance.web.*.public_ip
}
output "mysqlAttributes" {
  value = aws_instance.mysql.public_ip
}
# Get value after Script "terraform output -json ec2_mysql_ip | jq .[]"
