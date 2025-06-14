resource "aws_instance" "bastion" {
    ami = "ami-0160e8d70ebc43ee1"
    instance_type = "t2.micro"

    key_name = "gestionSSH"


    tags = {
      Name = "bastion"
    }
    network_interface {
        network_interface_id = aws_network_interface.ani-basti.id
        device_index         = 0
    }

  

}

resource "aws_network_interface" "ani-basti" {
    subnet_id = aws_subnet.sub-bas.id
    private_ips = ["192.168.2.150"]
    security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    "Name" = "ani-basti"
    "vpc" = "pub-0"
  }
  
}

resource "aws_eip" "basti" {
}

resource "aws_eip_association" "bastion_assoc" {
    instance_id = aws_instance.bastion.id
    allocation_id = aws_eip.basti.id
}




resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Permite acceso SSH"
  vpc_id      = aws_vpc.pub-0.id

  ingress {
    description = "SSH desde nuestra IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["79.116.83.60/32","79.117.217.136/32"] ## Cambiar para que sea actualizada
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Crear una Internet Gateway
resource "aws_internet_gateway" "mi_igw" {
  vpc_id = aws_vpc.pub-0.id
  tags = {
    Name = "mi-igw"
  }
}


resource "null_resource" "wait_ssh" {
  depends_on = [aws_instance.bastion]

  provisioner "local-exec" {
    command = "Start-sleep 40"

    interpreter = [ "Powershell", "-Command" ]
    
  }
  
}





resource "null_resource" "copy_private_key" {
  depends_on = [ null_resource.wait_ssh]
    provisioner "local-exec" {
      command = "scp -i ..\\terraform\\keys\\gestionSSH.pem -o StrictHostKeyChecking=no ..\\terraform\\keys\\gestionSSH.pem ubuntu@${aws_eip.basti.public_ip}:~/.ssh/id_ansible"
    }
  
}


resource "null_resource" "copy_files" {
  depends_on = [ null_resource.wait_ssh]
    provisioner "local-exec" {
      command = "scp -i ..\\terraform\\keys\\gestionSSH.pem -r -o StrictHostKeyChecking=no archivosPermanentes\\* ubuntu@${aws_eip.basti.public_ip}:~/archivosPermanentes"
      
    }
  
}


resource "null_resource" "exec_ansible" {
  depends_on = [ null_resource.aprovisionamiento_post_ssh,
                 aws_instance.srv_cont ]

    provisioner "remote-exec" {
      inline = ["bash /home/ubuntu/archivosPermanentes/main_ansible.sh"]      
    }

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = file("../terraform/keys/gestionSSH.pem")
        host = aws_eip.basti.public_ip
      }
  
}



resource "null_resource" "aprovisionamiento_post_ssh" {
  
  depends_on = [ null_resource.copy_private_key,
                 null_resource.copy_files ]
  
  provisioner "remote-exec" {
      inline = [
        "sudo chmod 600 ~/.ssh/id_ansible",
        "sudo apt update",
        "sudo apt install -y ansible",
        "scp -i ~/.ssh/id_ansible -r -o StrictHostKeyChecking=no ~/archivosPermanentes/cont/* ubuntu@${aws_instance.srv_cont.private_ip}:~/",
        ]

      connection {
        type = "ssh"
        user = "ubuntu"
        private_key = file("../terraform/keys/gestionSSH.pem")
        host = aws_eip.basti.public_ip
      }

    }
}


