terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "us-west-2"
}

# Create vpc

resource "aws_vpc" "tvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terra"
  } 
}

# Internet Gateway
resource "aws_internet_gateway" "tgw" {
  vpc_id = aws_vpc.tvpc.id

  tags = {
    Name = "terra"
  }
}

# Create Custom Route Table

resource "aws_route_table" "trt" {
  vpc_id = aws_vpc.tvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tgw.id
  }

  tags = {
    Name = "terra"
  }
}

# Create a Subnet 
resource "aws_subnet" "tsn" {
  vpc_id     = aws_vpc.tvpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "terra"
  }
}

# Associate subnet with Route Table
resource "aws_route_table_association" "trtac" {
  subnet_id      = aws_subnet.tsn.id
  route_table_id = aws_route_table.trt.id
}

# Create Security Group to allow port 22,80,443
resource "aws_security_group" "tsg" {
  name        = "allow ports"
  description = "Allow traffic"
  vpc_id      = aws_vpc.tvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "terra"
  }
}

# Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "tnic" {
  subnet_id       = aws_subnet.tsn.id
  private_ips     = ["10.0.1.30"]
  security_groups = [aws_security_group.tsg.id]
}

# add a elastic ip to assosicate with the instance

resource "aws_eip" "tepi" {
  instance = aws_instance.tinst.id
  vpc      = true
}

output "server_public_ip" {
  value = aws_eip.tepi.public_ip
}

# Create Ubuntu server and install docker, and compose up

resource "aws_instance" "tinst" {
  ami               = "ami-04aa685cc800320b3"
  instance_type     = "t3.medium"
  key_name          = "demo-key-pair"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.tnic.id
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apt-transport-https curl gnupg-agent ca-certificates software-properties-common -y
                sudo apt install apt-transport-https ca-certificates curl software-properties-common
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
                apt-cache policy docker-ce
                sudo apt install docker-ce -y
                sudo systemctl status docker
                git clone https://github.com/NuwanUdara/Docker-compose-example.git
                cd Docker-compose-example/
                cd 'Docker compose and Docker FIles Final'/
                sudo docker compose up
                EOF
  tags = {
    Name = "Terra"
  }
}