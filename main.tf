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

# vpc privada -- priv-0

resource "aws_vpc" "priv-0" {
  cidr_block = "192.168.1.0/24"
  tags = {
    Name = "priv-0"
    vpc  = "priv-0"
  }
}

# vpc publica -- pub-0

resource "aws_vpc" "pub-0" {
  cidr_block = "192.168.2.0/24"
  tags = {
    Name = "pub-0"
    vpc  = "pub-0"
  }
}


# vpc publica -- pub-1

resource "aws_vpc" "pub-1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "pub-1"
    vpc  = "pub-1"
  }
}

## Subred 192.168.1.0/24 sub_0
resource "aws_subnet" "sub-0" {
  vpc_id = aws_vpc.priv-0.id
  cidr_block = "192.168.1.0/24"
  

  tags = {
    Name = "sub-0"
  }
}

resource "aws_subnet" "sub-1" {
  vpc_id = aws_vpc.pub-0.id
  cidr_block = "192.168.2.0/24"


  tags = {
    Name = "sub-1"
  }
}

resource "aws_subnet" "sub-2" {
  vpc_id = aws_vpc.pub-1.id
  cidr_block = "10.0.0.0/16"
  

  tags = {
    Name = "sub-2"
  }
}

### EC2 Servicios y Contenedores

## srv_cont
resource "aws_instance" "srv_cont" {
  ami           = "ami-0160e8d70ebc43ee1"
  instance_type = "t2.micro" # Cambiar a t3.micro cuando hagamos la prueba real
  network_interface {
    network_interface_id = aws_network_interface.ani-srv_cont.id
    device_index         = 0 # Orden de prioridad de la tarjeta de red (Por si tiene mas de una)
  }
  key_name = "gestionSSH"
  tags = {
    "Name" = "srv_cont"
    "vpc"  = "priv-0"
  }
}

# Tarjeta de red srv_cont

resource "aws_network_interface" "ani-srv_cont" {
  subnet_id = aws_subnet.sub-0.id
  private_ips = ["192.168.1.150"]
  security_groups = [ aws_security_group.ssh_sg.id ] # Aplicacion del grupo de seguridad para permitir ssh

  tags = {
    "Name" = "ani-srv_cont"
    "vpc"  = "priv-0"
  }
}

## DC0

resource "aws_instance" "DC0" {
  ami = "ami-050351bdd0093f00e" # Windows server 2019. Cambiar a 2025
  instance_type = "t2.micro" # Cambiar a t3.small

  network_interface {
    network_interface_id = aws_network_interface.ani-dc0.id
    device_index         = 0
    
  }
  key_name = "gestionSSH"
  


  tags = {
    "Name" = "DC0"
    "vpc"  = "priv-0"
  }

}

# Tarjeta de red DC0

resource "aws_network_interface" "ani-dc0" {
  subnet_id = aws_subnet.sub-0.id
  private_ips = ["192.168.1.5"]
  security_groups = [ aws_security_group.ssh_sg.id ] # Aplicacion del grupo de seguridad para permitir ssh

  tags = {
    "Name" = "ani-dc0"
    "vpc" = "priv-0"
  }
  
}


## Web

resource "aws_instance" "Web" {
  ami = "ami-0160e8d70ebc43ee1" # Ubuntu 24.04 LTS
  instance_type = "t2.micro" 

  network_interface {
    network_interface_id = aws_network_interface.ani-web.id
    device_index         = 0
  }

  tags = {
    "Name" = "Web"
    "vpc"  = "priv-0"
  }

}

# Tarjeta de red Web

resource "aws_network_interface" "ani-web" {
  subnet_id = aws_subnet.sub-1.id
  private_ips = ["192.168.2.5"]
  tags = {
    "Name" = "ani-web"
    "vpc" = "priv-0"
    "sub" = "sub1"
  }
  
}

## TPOT


resource "aws_instance" "Tpot" {
  ami = "ami-0160e8d70ebc43ee1" # ubuntu
  instance_type = "t2.micro" # Cambiar a t3a.large

  network_interface {
    network_interface_id = aws_network_interface.ani-tpot.id
    device_index         = 0
    
  }

  key_name = "gestionSSH"
  


  tags = {
    "Name" = "Tpot"
    "vpc"  = "pub-1"
  }

}

# Tarjeta de red Tpot

resource "aws_network_interface" "ani-tpot" {
  subnet_id = aws_subnet.sub-2.id
  private_ips = ["10.0.1.2"]

  tags = {
    "Name" = "ani-tpot"
    "vpc" = "pub-1"
  }
  
}



## Bucket S3 backups

resource "aws_s3_bucket" "backups" {
  tags = {
    Name        = "backups"
    Environment = "Dev"
  }
}


## Aurora

resource "aws_rds_cluster" "auroraDBCluster" {
  cluster_identifier   = "aurora-cluster"
  engine               = "aurora-mysql"
  skip_final_snapshot  = true
  master_username = "admin"
  master_password = "PakitoChokolatero123"

  serverlessv2_scaling_configuration {
    min_capacity = 0.5  # En ACUs (Aurora Capacity Units)
    max_capacity = 2.0
  }

    # Esto activa Serverless v2
  
}

resource "aws_rds_cluster_instance" "auroraDB" {
  identifier         = "aurora-instance"
  cluster_identifier = aws_rds_cluster.auroraDBCluster.id
  instance_class     = "db.t3.medium"
  engine             = "aurora-mysql"
  publicly_accessible     = false
}



###### Security group que permite ssh

resource "aws_security_group" "ssh_sg" {
  name = "ssh-sg"
  description = "Permitir SSH"
  vpc_id = aws_vpc.priv-0.id

  ingress {
    description = "SSH desde cualquier sitio"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

