


# 1. Create vpc

resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

# 2. Create Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id


}
# 3. Create Custom Route Table

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Prod"
  }
}

# 4. Create a Subnet 

resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod-subnet"
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}
# 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. Create a network interface with an ip in the subnet that was created in step 4

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}
# 8. Assign an elastic IP to the network interface created in step 7

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}

# 9. Create Ubuntu server and install/enable apache2

resource "aws_instance" "web-server-instance" {
  ami               = "ami-085925f297f89fce1"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "main-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo your very first web server > /var/www/html/index.html'
                EOF
  tags = {
    Name = "web-server"
  }
}



output "server_private_ip" {
  value = aws_instance.web-server-instance.private_ip

}

output "server_id" {
  value = aws_instance.web-server-instance.id
}


# resource "<provider>_<resource_type>" "name" {
#     config options.....
#     key = "value"
#     key2 = "another value"
# }







# /*resource "aws_instance" "Server1-Jenkins" {
#     count=1
#     instance_type = "t2.micro"
#     ami = var.ami
#     security_groups = [aws_security_group.default-sg.id]
#     subnet_id = aws_subnet.private_subnet
#     user_data = <<EOF

#     #! /bin/bash

#     sudo yum install update
#     sudo yum install -y httpd
#     sudo systemctl start httpd
#     sudo systemctl enable httpd
#     echo "<h1> Deployed using Terrafrm</h1>" | sudo vi /var/www/html/index.html

#     EOF
#     key_name = ""
#     tags {
#          Name = "terraform-Server"
            
#      }


  
# }

# resource "aws_instance" "Server1-Application" {
#     count=1
#     instance_type = "t2.micro"
#     subnet_id = aws_subnet.public_subnet.id
#     ami = var.ami
#     security_groups = aws_security_group.default-sg.id
#     key_name = ""
#     tags {
#          Name = "terraform-Server"
         
#      }


  
# }



# resource "aws_vpc" "vpc" {
#   cidr_block           = var.vpc_cidr
  
#   tags = {
#     Name        = "vpc"
    
#   }
# }
# /*==== Subnets ======*/
# /* Internet gateway for the public subnet */
# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.vpc.id
#   tags = {
#     Name        = "igw"
    
#   }
# }/* Elastic IP for NAT */
# resource "aws_eip" "nat_eip" {
#   vpc        = true
#   associate_with_private_ip = "10.0.1.50"
#   depends_on = [aws_internet_gateway.igw]
# }

# /* NAT */
# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id     = ["aws_subnet.public_subnet.id"]
#   depends_on    = [aws_internet_gateway.igw]
#   tags = {
#     Name        = "nat"
    
#   }
# }

# /* Public subnet */
# resource "aws_subnet" "public_subnet" {
#   vpc_id                  = aws_vpc.vpc.id
  
#   cidr_block              = var.public_subnets_cidr
#   availability_zone       = var.availability_zones
#   map_public_ip_on_launch = true
#   tags = {
#     Name        = "public-subnet"
    
#   }
# }

# resource "aws_subnet" "private_subnet" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = var.private_subnets_cidr
#   availability_zone       = var.availability_zones
#   map_public_ip_on_launch = false
#   tags = {
#     Name        = "private-subnet"
    
#   }
# }

# /* Routing table for private subnet */
# resource "aws_route_table" "private" {
#   vpc_id = "${aws_vpc.vpc.id}"
#   tags = {
#     Name        = "private-route-table"
   
#   }
# }
# /* Routing table for public subnet */
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.vpc.id
#   tags = {
#     Name        = "public-route-table"
   
#   }
# }
# resource "aws_route" "public_internet_gateway" {
#   route_table_id         = "${aws_route_table.public.id}"
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = ["aws_internet_gateway.igw.id"]
# }
# resource "aws_route" "private_nat_gateway" {
#   route_table_id         = "${aws_route_table.private.id}"
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = "${aws_nat_gateway.nat.id}"
# }
# /* Route table associations */
# resource "aws_route_table_association" "public" {
  
#   subnet_id      = aws_subnet.public_subnet.id
#   route_table_id = aws_route_table.public.id
# }
# resource "aws_route_table_association" "private" {
  
#   subnet_id      = aws_subnet.private_subnet.id
#   route_table_id = aws_route_table.private.id
# }
# /*==== VPC's Default Security Group ======*/
# resource "aws_security_group" "default-sg" {
#   name        = "default-sg"
#   description = "Default security group to allow inbound/outbound from the VPC"
#   //vpc_id      = aws_vpc.vpc.id
#   //depends_on  = [aws_vpc.vpc.id]
  
#   ingress {
#     from_port = "0"
#     to_port   = "0"
#     protocol  = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]

    
#   }
  
#   egress {
#     from_port = "0"
#     to_port   = "0"
#     protocol  = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }
  
 
# }

  

#   */
 