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
  region = "us-west-2"
}

# AWS EC2 Instance
resource "aws_instance" "minecraft_server" {
  ami                    = "ami-04999cd8f2624f834"
  instance_type          = "t2.large"
  key_name               = "minecraft_key"
  subnet_id              = aws_subnet.minecraft_subnet.id
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  tags = {
    Name = "minecraft server"
  }
}
