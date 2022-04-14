provider "aws" {
  region = "eu-west-3"
}

resource "aws_vpc" "vpc-10-0-0-0" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
 
  tags = {
    Name = "vpc-10-0-0-0"
  }
}

resource "aws_subnet" "AZ1-Public-Sub" {
  vpc_id     = aws_vpc.vpc-10-0-0-0.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "AZ1-Public-Sub"
  }
}

resource "aws_subnet" "AZ1-Private-Sub" {
  vpc_id     = aws_vpc.vpc-10-0-0-0.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "AZ1-Private-Sub"
  }
}

resource "aws_subnet" "AZ1-MGT-Sub" {
  vpc_id     = aws_vpc.vpc-10-0-0-0.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "eu-west-3a"
  //map_public_ip_on_launch = true

  tags = {
    Name = "AZ1-MGMT-Sub"
  }
}

resource "aws_subnet" "AZ2-Public-Sub" {
  vpc_id     = aws_vpc.vpc-10-0-0-0.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-3b"

  tags = {
    Name = "AZ2-Public-Sub"
  }
}

resource "aws_subnet" "AZ2-Private-Sub" {
  vpc_id     = aws_vpc.vpc-10-0-0-0.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-3b"

  tags = {
    Name = "AZ2-Private-Sub"
  }
}

resource "aws_subnet" "AZ2-MGT-Sub" {
  vpc_id     = aws_vpc.vpc-10-0-0-0.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "eu-west-3b"
  //map_public_ip_on_launch = true

  tags = {
    Name = "AZ2-MGMT-Sub"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-10-0-0-0.id

  tags = {
    Name = "IGW-tf"
  }
}


resource "aws_network_interface" "PA-AZ1-Untrust" {
  subnet_id       = aws_subnet.AZ1-Public-Sub.id
  security_groups = [aws_security_group.allow-pa-sg.id]
  source_dest_check = false

  tags = {
    Name = "PA-AZ1-Untrust"
  }
}

resource "aws_network_interface" "PA-AZ1-MGT" {
  subnet_id       = aws_subnet.AZ1-MGT-Sub.id
  security_groups = [aws_security_group.allow-mgt-sg.id]

  tags = {
    Name = "PA-AZ1-MGT"
  }
}

resource "aws_network_interface" "PA-AZ1-Trust" {
  subnet_id       = aws_subnet.AZ1-Private-Sub.id 
  security_groups = [aws_security_group.allow-pa-sg.id]
  source_dest_check = false
  
  
  tags = {
    Name = "PA-AZ1-Trust"
  }
  
}

resource "aws_network_interface" "PA-AZ2-Untrust" {
  subnet_id       = aws_subnet.AZ2-Public-Sub.id
  security_groups = [aws_security_group.allow-pa-sg.id]
  source_dest_check = false

  tags = {
    Name = "PA-AZ2-Untrust"
  }
}

resource "aws_network_interface" "PA-AZ2-MGT" {
  subnet_id       = aws_subnet.AZ2-MGT-Sub.id
  security_groups = [aws_security_group.allow-mgt-sg.id]

  tags = {
    Name = "PA-AZ2-MGT"
  }
}

resource "aws_network_interface" "PA-AZ2-Trust" {
  subnet_id       = aws_subnet.AZ2-Private-Sub.id
  security_groups = [aws_security_group.allow-pa-sg.id]
  source_dest_check = false
  
  tags = {
    Name = "PA-AZ2-Trust"
  }
  
}

/*resource "aws_eip_association" "PA1-MGT-EIP" {              //기존에 존재하는 EIP를 사용할 경우
  network_interface_id = aws_network_interface.PA-AZ1-MGT.id
  allocation_id = "eipalloc-049695fed4edf2a8d"
}

resource "aws_eip_association" "PA2-MGT-EIP" {
  network_interface_id = aws_network_interface.PA-AZ2-MGT.id
  allocation_id = "eipalloc-034128633a0026383"
}*/

resource "aws_eip" "az1_pa_mgt" {                                    //EIP를 새로 생성하면서 매핑시킬 경우
  network_interface = aws_network_interface.PA-AZ1-MGT.id
  
  tags = {
    Name = "PA-AZ1-MGT-EIP"
  }
}

resource "aws_eip" "az2_pa_mgt" {
  network_interface = aws_network_interface.PA-AZ2-MGT.id
  
  tags = {
    Name = "PA-AZ2-MGT-EIP"
  }
}


resource "aws_route_table" "Public-RTB" {
  vpc_id = aws_vpc.vpc-10-0-0-0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-RTB"
  }
}


resource "aws_route_table_association" "rt-pub-as1-vpc-10-0-0-0" { //AZ1 Public RTB Association
  subnet_id      = aws_subnet.AZ1-Public-Sub.id
  route_table_id = aws_route_table.Public-RTB.id
}

resource "aws_route_table_association" "rt-pub-as2-vpc-10-0-0-0" { //AZ2 Public RTB Association
  subnet_id      = aws_subnet.AZ2-Public-Sub.id
  route_table_id = aws_route_table.Public-RTB.id
}

resource "aws_route_table_association" "rt-mgt-as1-vpc-10-0-0-0" { //AZ1 Public RTB Association
  subnet_id      = aws_subnet.AZ1-MGT-Sub.id
  route_table_id = aws_route_table.Public-RTB.id
}

resource "aws_route_table_association" "rt-mgt-as2-vpc-10-0-0-0" { //AZ2 Public RTB Association
  subnet_id      = aws_subnet.AZ2-MGT-Sub.id
  route_table_id = aws_route_table.Public-RTB.id
}


resource "aws_route_table" "AZ1-Private-RTB" { //AZ1 Private RTB
  vpc_id = aws_vpc.vpc-10-0-0-0.id

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_network_interface.PA-AZ1-Trust.id
  }
 
  tags = {
    Name = "AZ1-Private-RTB"
  }
}

resource "aws_route_table" "AZ2-Private-RTB" { //AZ2 Private RTB
  vpc_id = aws_vpc.vpc-10-0-0-0.id

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id  = aws_network_interface.PA-AZ2-Trust.id
  }
 
  tags = {
    Name = "AZ2-Private-RTB"
  }
}

resource "aws_route_table_association" "rt-pri1-as1-vpc-10-0-0-0" { //AZ1 Private RTB Association
  subnet_id      = aws_subnet.AZ1-Private-Sub.id
  route_table_id = aws_route_table.AZ1-Private-RTB.id
}

resource "aws_route_table_association" "rt-pri2-as2-vpc-10-0-0-0" { //AZ1 Private RTB Association
  subnet_id      = aws_subnet.AZ2-Private-Sub.id
  route_table_id = aws_route_table.AZ2-Private-RTB.id
}


