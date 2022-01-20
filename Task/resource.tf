resource "aws_vpc" "QA" {

    cidr_block = "10.0.0.0/16"
    
    tags{
        Name="QA"
    }
  
}

resource "aws_internet_gateway" "igw" {

    vpc_id = aws_vpc.QA.id
  
}

resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.QA.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags{
        Name= "public-subnet"
    }
  
}
resource "aws_subnet" "private-subnet" {
    vpc_id = aws_vpc.QA.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"

    tags{
        Name= "private-subnet"
    }
  
}

resource "aws_route_table" "public-rt" {

    vpc_id = aws_vpc.QA.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
  
}

resource "aws_route_table" "private-rt" {

    vpc_id = aws_vpc.QA.id
    route {
        cidr_block = "10.0.0.0/16"
        
    }
  
}

