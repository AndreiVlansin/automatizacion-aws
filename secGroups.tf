###### Security group que permite ssh

resource "aws_security_group" "ssh_sg_priv-0" {
  name = "ssh_sg_priv-0"
  description = "Permitir SSH desde el grupo de seguridad del bastion para las maquinas de priv0"
  vpc_id = aws_vpc.priv-0.id

  ingress {
    description = "SSH desde el bastion"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks      = ["192.168.2.150/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_security_group" "ssh_sg_pub-0" {
  name = "ssh_sg_pub-0"
  description = "Permitir SSH desde el grupo de seguridad del bastion para las maquinas de priv0"
  vpc_id = aws_vpc.pub-0.id

  ingress {
    description = "SSH desde el bastion"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks      = ["192.168.2.150/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}


resource "aws_security_group" "ssh_sg_pub-1" {
  name = "ssh_sg_pub-1"
  description = "Permitir SSH desde el grupo de seguridad del bastion para las maquinas de priv0"
  vpc_id = aws_vpc.pub-1.id

  ingress {
    description = "SSH desde el bastion"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks      = ["192.168.2.150/32"]
  }

  ingress {
  description = "SSH desde el bastion - Puerto 64295"
  from_port   = 64295
  to_port     = 64295
  protocol    = "tcp"
  cidr_blocks = ["192.168.2.150/32"]
}


  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_security_group" "http_internet-sg" {
  name        = "http_internet-sg"
  description = "Permitir acceso HTTP desde internet"
  vpc_id      = aws_vpc.pub-0.id

  ingress {
    description      = "Permitir HTTP desde internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]        
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                 
    cidr_blocks = ["0.0.0.0/0"]        
  }
}

resource "aws_security_group" "http_lb-sg" {
  name        = "http_lb-sg"
  description = "Permitir acceso HTTP desde el load balancer"
  vpc_id      = aws_vpc.pub-0.id

  ingress {
    description      = "Permitir HTTP desde el load balancer"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                 
    cidr_blocks = ["0.0.0.0/0"]        
  }
}

resource "aws_security_group" "allow_ping" {
  name        = "allow-ping"
  description = "Permitir ping (ICMP Echo Request) desde cualquier IP"
  vpc_id      = aws_vpc.pub-0.id

  ingress {
    description      = "Allow ICMP Echo Request"
    from_port        = 8            
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"         
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tpot_dashboard-sg" {
  name        = "tpot_dashboard-sg"
  description = "T-Pot dashboard y ssh access"
  vpc_id      = aws_vpc.pub-1.id


  ingress {
    from_port = 64297
    to_port = 64297
    protocol = "TCP"
    cidr_blocks = ["192.168.2.150/32"]
  }
  ingress {
    from_port   = 64295
    to_port     = 64295
    protocol    = "tcp"
    cidr_blocks = ["192.168.2.150/32"]  
  }

  ingress {
    from_port   = 10
    to_port     = 6400
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_security_group" "kuma_dashboard-sg" {
  name        = "kuma_dashboard-sg"
  description = "kuma dashboard access"
  vpc_id      = aws_vpc.priv-0.id


  ingress {
    from_port = 3001
    to_port = 3001
    protocol = "TCP"
    cidr_blocks = ["192.168.2.150/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}



resource "aws_security_group" "winrm" {
  name        = "winrm-sg"
  description = "Allow WinRM traffic"
  vpc_id = aws_vpc.priv-0.id

  ingress {
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["192.168.2.150/32"]  # desde el bastion
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}