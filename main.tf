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




# ## Web

# resource "aws_instance" "Web" {
#   ami = "ami-0160e8d70ebc43ee1" # Ubuntu 24.04 LTS
#   instance_type = "t2.micro" 

#   network_interface {
#     network_interface_id = aws_network_interface.ani-web.id
#     device_index         = 0
#   }

#   tags = {
#     "Name" = "Web"
#     "vpc"  = "priv-0"
#   }

#   key_name = "gestionSSH"

# }



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




## Bucket S3 backups

resource "aws_s3_bucket" "backups" {
  tags = {
    Name        = "backups"
    Environment = "Dev"
  }
}


## Aurora

# resource "aws_rds_cluster" "auroraDBCluster" {
#   cluster_identifier   = "aurora-cluster"
#   engine               = "aurora-mysql"
#   skip_final_snapshot  = true
#   master_username = "admin"
#   master_password = "$$$P4k1t0Ch0k0l4t3r0123###"

#   serverlessv2_scaling_configuration {
#     min_capacity = 0.5  # En ACUs (Aurora Capacity Units)
#     max_capacity = 2.0
#   }

#     # Esto activa Serverless v2
  
# }

# resource "aws_rds_cluster_instance" "auroraDB" {
#   identifier         = "aurora-instance"
#   cluster_identifier = aws_rds_cluster.auroraDBCluster.id
#   instance_class     = "db.serverless" #Si da errores cambiar a t3.medium
#   engine             = "aurora-mysql"
#   publicly_accessible     = false
# }



