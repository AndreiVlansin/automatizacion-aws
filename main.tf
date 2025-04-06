terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }
}


variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}



provider "aws" {
  region     = "eu-west-3"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

# vpc privada -- priv-0 y dos subredes sub1 y sub2

resource "aws_vpc" "priv-0" {
  cidr_block = "192.168.1.0/24"
  tags = {
    Name = "priv-0"
    vpc  = "priv-0"
  }
}

resource "aws_subnet" "sub1-priv-0" {
  vpc_id     = aws_vpc.priv-0.id
  cidr_block = "192.168.1.0/25"

  tags = {
    Name = "sub1-priv-0"
    vpc  = "priv-0"
    sub  = "sub1"
  }
}

resource "aws_subnet" "sub2-priv-0" {
  vpc_id     = aws_vpc.priv-0.id # Esto le asigna la id que se cree para la vpc priv-0
  cidr_block = "192.168.1.128/25"


  tags = {
    Name = "sub2-priv-0"
    vpc  = "priv-0"
    sub  = "sub2"
  }
}




# EC2 Servicios y Contenedores
resource "aws_instance" "srv_cont" {
  ami           = "ami-0160e8d70ebc43ee1"
  instance_type = "t2.micro" # Cambiar a t3.micro cuando hagamos la prueba real
  network_interface {
    network_interface_id = aws_network_interface.ani-srv_cont.id
    device_index         = 0 # Orden de prioridad de la tarjeta de red (Por si tiene mas de una)
  }


  tags = {
    "Name" = "srv_cont"
    "vpc"  = "priv-0"
  }
}


# Tarjeta de red srv_cont

resource "aws_network_interface" "ani-srv_cont" {
  subnet_id   = aws_subnet.sub2-priv-0.id
  private_ips = ["192.168.1.150"]

  tags = {
    "Name" = "ani-srv_cont"
    "vpc"  = "priv-0"
    "sub"  = "sub2"
  }
}

