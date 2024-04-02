terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.31.0"
    }
  }
}

provider "aws" {
    alias = "us"
    region = "us-west-1"
    access_key = ""
    secret_key = ""
}

# 1. Create vpc
resource "aws_vpc" "dev-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "dev-vpc"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.dev-vpc.id
}

# 3. Create Custom Route Table
resource "aws_route" "name" {
  
}

# 4. Create a Subnet
resource "aws_subnet" "dev-subnet" {
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = aws_vpc.dev-vpc.cidr_block
  availability_zone = "${data.aws_region.current.name}a"
  
  tags = {
    Name = "dev-subnet"
  }
}

# 5. Associate subnet with Route Table
# 6. Create Security Group to allow port 22,80,443
# 7. Create a network interface with an ip in the subnet that was created in step 4
# 8. Assign an elastic IP to the network interface created in step 7
# 9. Create Ubuntu server and install/enable apache2


# resource "aws_instance" "vpn-server" {
#     ami = "ami-0588c11374527e516"
#     instance_type = "t2.micro"

#     tags = {
#       Name = "Vpn Server"
#     }
# }
