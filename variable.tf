
variable "ssh_port" {
    default = 22
  
}

variable "ami" {
    default = "ami-08e4e35cccc6189f4"
  
}

variable "region" {
  description = "AWS Deployment region.."
  default = "us-east-1"
}

variable "vpc_cidr" {

    default = "172.20.0.0/16"
  
}

variable "public_subnets_cidr" {

    default = "172.20.10.0/24"
  
}

variable "private_subnets_cidr" {
    default = "172.20.20.0/24"
  
}
variable "availability_zones" {
    default = "us-east-1a"
}