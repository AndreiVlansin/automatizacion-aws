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
  instance_type = "t2.micro" 
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
  ami = "ami-050351bdd0093f00e"
  instance_type = "t3.medium"

  network_interface {
    network_interface_id = aws_network_interface.ani-dc0.id
    device_index         = 0
    
  }
  
  
  user_data = <<-EOF
    <powershell>
    # Activar winrm para ansible
    Enable-PSRemoting -Force -SkipNetworkProfileCheck
    winrm quickconfig -q
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    Restart-Service WinRM

    # Crea usuario ansible_user
    $username = "ansible_user"
    $password = "P@ssw0rd123!" | ConvertTo-SecureString -AsPlainText -Force
    New-LocalUser -Name $username -Password $password
    Add-LocalGroupMember -Group "Administrators" -Member $username

    # Permite winrm para firewall
    netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in action=allow protocol=TCP localport=5985
  </powershell>
  EOF





  tags = {
    "Name" = "DC0"
    "vpc"  = "priv-0"
  }

}


## TPOT


resource "aws_instance" "Tpot" {
  ami = "ami-0160e8d70ebc43ee1" # ubuntu
  instance_type = "t3a.xlarge"

  network_interface {
    network_interface_id = aws_network_interface.ani-tpot.id
    device_index         = 0
    
  }

  

  key_name = "gestionSSH"
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted   = false
  }
 
    


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

resource "aws_rds_cluster" "auroraDBCluster" {
  cluster_identifier   = "aurora-cluster"
  engine               = "aurora-mysql"
  skip_final_snapshot  = true
  master_username = "admin"
  master_password = "$$$P4k1t0Ch0k0l4t3r0123###"

  serverlessv2_scaling_configuration {
    min_capacity = 0.5 
    max_capacity = 2.0
  }

    # Esto activa Serverless v2
  
}

resource "aws_rds_cluster_instance" "auroraDB" {
  identifier         = "aurora-instance"
  cluster_identifier = aws_rds_cluster.auroraDBCluster.id
  instance_class     = "db.serverless" 
  engine             = "aurora-mysql"
  publicly_accessible     = false
}



