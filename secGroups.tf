###### Security group que permite ssh

resource "aws_security_group" "ssh_sg" {
  name = "ssh-sg"
  description = "Permitir SSH desde el grupo de seguridad del bastion para las maquinas de priv0"
  vpc_id = aws_vpc.priv-0.id

  ingress {
    description = "SSH desde el bastion"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
    
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

