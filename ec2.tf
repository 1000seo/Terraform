resource "aws_security_group" "allow-pa-sg" {
  name        = "allow-pa-sg"
  description = "Allow pa-sg inbound traffic"
  vpc_id      = aws_vpc.vpc-10-0-0-0.id

  ingress {
    description      = "PA from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-pa-sg"
  }
}

resource "aws_security_group" "allow-mgt-sg" { 
  name        = "allow-pa-mgt-sg"
  description = "Allow pa-mgt inbound traffic"
  vpc_id      = aws_vpc.vpc-10-0-0-0.id

  ingress {                                  
    description      = "allow-443"
    from_port        = 0
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  ingress {
    description      = "allow-22"
    from_port        = 0
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-pa-mgt-sg"                
  }
}


resource "aws_instance" "AZ1_Paloalto" {
  ami = "ami-01f2432190130a2c6"
  instance_type = "c5.xlarge"
  key_name = "aws_paris_key"
  availability_zone = "eu-west-3a"
  user_data = "mgmt-interface-swap=enable"

  
  network_interface {
    network_interface_id = aws_network_interface.PA-AZ1-MGT.id
    device_index         = 1
  }
  
  network_interface {
    network_interface_id = aws_network_interface.PA-AZ1-Untrust.id
    device_index         = 0
  }
  
 network_interface {
    network_interface_id = aws_network_interface.PA-AZ1-Trust.id
    device_index         = 2
  }

  root_block_device {
    volume_size = 60
    
  }
  
  tags = {
    Name = "Paloalto_AZ1_tf"
  }
}

resource "aws_instance" "AZ2_Paloalto" {
  ami = "ami-01f2432190130a2c6"
  instance_type = "c5.xlarge"
  key_name = "aws_paris_key"
  user_data = "mgmt-interface-swap=enable"
  
    network_interface {
    network_interface_id = aws_network_interface.PA-AZ2-MGT.id
    device_index         = 1
  }
  
  network_interface {
    network_interface_id = aws_network_interface.PA-AZ2-Untrust.id
    device_index         = 0
  }
  
 network_interface {
    network_interface_id = aws_network_interface.PA-AZ2-Trust.id
    device_index         = 2
  }
  
  
  root_block_device {
    volume_size = 60
    
  }
  
  tags = {
    Name = "Paloalto_AZ2_tf"
  }

}