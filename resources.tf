resource "aws_instance" "Server1-Jenkins" {
    count=1
    instance_type = "t2.micro"
    ami = var.ami
    security_groups = aws_security_group.default-sg.id
    subnet_id = aws_subnet.private_subnet
    user_data = <<EOF

    #! /bin/bash

    sudo yum install update
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "<h1> Deployed using Terrafrm</h1>" | sudo vi /var/www/html/index.html

    EOF
    key_name = ""
    tags {
         Name = "terraform-Server"
            
     }


  
}

resource "aws_instance" "Server1-Application" {
    count=1
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public_subnet.id
    ami = var.ami
    security_groups = aws_security_group.default-sg.id
    key_name = ""
    tags {
         Name = "terraform-Server"
         
     }


  
}



resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  
  tags = {
    Name        = "vpc"
    
  }
}
/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "igw"
    
  }
}/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = aws_internet_gateway.id
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  depends_on    = aws_internet_gateway.id
  tags = {
    Name        = "nat"
    
  }
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  
  cidr_block              = var.public_subnets_cidr
  availability_zone       = var.availability_zones
  map_public_ip_on_launch = true
  tags = {
    Name        = "public-subnet"
    
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets_cidr
  availability_zone       = var.availability_zones
  map_public_ip_on_launch = false
  tags = {
    Name        = "private-subnet"
    
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "private-route-table"
   
  }
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "public-route-table"
   
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}
/* Route table associations */
resource "aws_route_table_association" "public" {
  
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}
/*==== VPC's Default Security Group ======*/
resource "aws_security_group" "default-sg" {
  name        = "default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = aws_vpc.vpc
  
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks      = "0.0.0.0/0"

    
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks      = "0.0.0.0/0"
  }
  
 
}

  

  
 