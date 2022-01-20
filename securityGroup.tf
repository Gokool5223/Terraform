resource "aws_security_group" "terraform" {

    name = "Terraform Security"
    description = "Allow Traffic"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "${var.ssh_port}"
        cidr_blocks = "0.0.0.0/0"
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = "0.0.0.0/0"
    }

    tags = "Terraform-SG"

  
}