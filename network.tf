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
resource "aws_subnet" "sub-priv0" {
  vpc_id = aws_vpc.priv-0.id
  cidr_block = "192.168.1.0/24"
  

  tags = {
    Name = "sub-priv0"
  }
}

resource "aws_subnet" "sub-pub0" {
  vpc_id = aws_vpc.pub-0.id
  cidr_block = "192.168.2.0/25"


  tags = {
    Name = "sub-pub0"
  }
}

resource "aws_subnet" "sub-bas" {
  vpc_id = aws_vpc.pub-0.id
  cidr_block = "192.168.2.128/25"
  map_public_ip_on_launch = true  # Permite IPs públicas


  tags = {
    Name = "sub-bas"
  }
}

resource "aws_subnet" "sub-pub1" {
  vpc_id = aws_vpc.pub-1.id
  cidr_block = "10.0.0.0/16"
  

  tags = {
    Name = "sub-pub1"
  }
}




# Tarjetas de red (ANI)

# Tarjeta de red Tpot

resource "aws_network_interface" "ani-tpot" {
  subnet_id = aws_subnet.sub-pub1.id
  private_ips = ["10.0.1.2"]
  security_groups = [ aws_security_group.ssh_sg_pub-1.id,
                      aws_security_group.tpot_dashboard-sg.id
  ]

  tags = {
    "Name" = "ani-tpot"
    "vpc" = "pub-1"
  }
  
}


# Tarjeta de red DC0

resource "aws_network_interface" "ani-dc0" {
  subnet_id = aws_subnet.sub-priv0.id
  private_ips = ["192.168.1.5"]
  security_groups = [ aws_security_group.ssh_sg_priv-0.id,
                      aws_security_group.winrm.id ] # Aplicacion del grupo de seguridad para permitir ssh

  tags = {
    "Name" = "ani-dc0"
    "vpc" = "priv-0"
  }
  
}


# Tarjeta de red srv_cont

resource "aws_network_interface" "ani-srv_cont" {
  subnet_id = aws_subnet.sub-priv0.id
  private_ips = ["192.168.1.150"]
  security_groups = [ aws_security_group.ssh_sg_priv-0.id,
                      aws_security_group.kuma_dashboard-sg.id ] # Aplicacion del grupo de seguridad para permitir ssh

  tags = {
    "Name" = "ani-srv_cont"
    "vpc"  = "priv-0"
  }
}


# VPC Peering

resource "aws_vpc_peering_connection" "pub2priv" {
    vpc_id = aws_vpc.pub-0.id
    peer_vpc_id = aws_vpc.priv-0.id
    auto_accept = true

    tags = {
      Name = "pub2priv"
    }
}

resource "aws_vpc_peering_connection" "pub2pub" {
  vpc_id = aws_vpc.pub-0.id
  peer_vpc_id = aws_vpc.pub-1.id
  auto_accept = true

  tags = {
    Name = "pub2pub"
  }
  
}


# Tablas de enrutamiento


resource "aws_route_table" "pub-0_rt" {
  vpc_id = aws_vpc.pub-0.id
  
  tags = {
    Name = "pub-0_rt"
  }
  
}


resource "aws_route_table" "priv-0_rt" {
  vpc_id = aws_vpc.priv-0.id
  
  tags = {
    Name = "priv-0_rt"
  }
}


resource "aws_route_table" "pub-1_rt" {
  vpc_id = aws_vpc.pub-1.id
  
  tags = {
    Name = "pub-1_rt"
  }
}


# pub-0 ----> priv-0
resource "aws_route" "pub02priv0" {
  route_table_id = aws_route_table.pub-0_rt.id
  destination_cidr_block = aws_vpc.priv-0.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.pub2priv.id
}

# pub-0 <---- priv-0
resource "aws_route" "priv02pub0" {
  route_table_id = aws_route_table.priv-0_rt.id
  destination_cidr_block = aws_vpc.pub-0.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.pub2priv.id
}

# pub-0 ----> pub-1
resource "aws_route" "pub02pub1" {
  route_table_id = aws_route_table.pub-0_rt.id
  destination_cidr_block = aws_vpc.pub-1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.pub2pub.id
}

# pub-0 ----> internet

resource "aws_route" "pub02internet" {
  route_table_id = aws_route_table.pub-0_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.mi_igw.id
}



# pub-0 <---- pub-1
resource "aws_route" "pub12pub0" {
  route_table_id = aws_route_table.pub-1_rt.id
  destination_cidr_block = aws_vpc.pub-0.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.pub2pub.id
}

# pub-1 -----> internet
resource "aws_route" "pub12internet" {
  route_table_id = aws_route_table.pub-1_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.tpot_igw.id
}






# Asociaciones a subredes

resource "aws_route_table_association" "sub-priv0_assoc" {
  subnet_id = aws_subnet.sub-priv0.id
  route_table_id = aws_route_table.priv-0_rt.id
   
}


resource "aws_route_table_association" "sub-pub0_assoc" {
 subnet_id = aws_subnet.sub-pub0.id
 route_table_id = aws_route_table.pub-0_rt.id
 
}



resource "aws_route_table_association" "sub-pub1_assoc" {
  subnet_id = aws_subnet.sub-pub1.id
  route_table_id = aws_route_table.pub-1_rt.id
   
}


resource "aws_route_table_association" "sub-bas_assoc" {
  subnet_id = aws_subnet.sub-bas.id
  route_table_id = aws_route_table.pub-0_rt.id
   
}

resource "aws_eip" "tipoti" {
}

resource "aws_eip_association" "tpot_assoc" {
    instance_id = aws_instance.Tpot.id
    allocation_id = aws_eip.tipoti.id
}

resource "aws_internet_gateway" "tpot_igw" {
  vpc_id = aws_vpc.pub-1.id
  tags = {
    Name = "tpot-igw"
  }
}