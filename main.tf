terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.44.0"
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
resource "aws_vpc" "Vpn-Vpc" {
  cidr_block = "100.68.0.0/18"
  enable_dns_hostnames = true
  tags = {
    Name = "Vpn-Vpc"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "Vpn-GW" {
  vpc_id = aws_vpc.Vpn-Vpc.id
  tags = {
    Name = "Vpn-GW"
  }
}

# 3. Create Custom Route Table
resource "aws_route_table" "Vpn-Routing-Table" {
  vpc_id = aws_vpc.Vpn-Vpc.id
  route {
    cidr_block = "100.68.0.0/18"
    gateway_id = aws_internet_gateway.Vpn-GW.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.Vpn-GW.id
  }
  tags = {
    Name = "Vpn-Routing-Tabble"
  }
}

# 4. Create a Subnet
resource "aws_subnet" "Vpn-Subnet" {
  vpc_id     = aws_vpc.Vpn-Vpc.id
  cidr_block = aws_vpc.Vpn-Vpc.cidr_block
  availability_zone = "${data.aws_region.current.name}"
  tags = {
    Name = "Vpn-Subnet"
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "Vpn-Subnet_Association" {
  subnet_id      = aws_subnet.Vpn-Subnet.id
  route_table_id = aws_route_table.Vpn-Routing-Table.id
}

# 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_tls" {
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.Vpn-Vpc.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.Vpn-Vpc.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = aws_vpc.Vpn-Vpc.ipv6_cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.Vpn-Vpc.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = aws_vpc.Vpn-Vpc.ipv6_cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.Vpn-Vpc.cidr_block
  from_port         = 22
  to_port           = 22
  ip_protocol          = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = aws_vpc.Vpn-Vpc.ipv6_cidr_block
  from_port         = 22
  to_port           = 22
  ip_protocol          = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

# 7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "test" {
  subnet_id       = aws_subnet.Vpn-Subnet.id
  private_ips     = ["100.68.0.5"]
  security_groups = [aws_security_group.allow_tls.id]

  attachment {
    instance     = aws_instance.vpn-server.id
    device_index = 1
  }
}

# 8. Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "bar" {
  domain = "vpc"

  instance                  = aws_instance.vpn-server.id
  associate_with_private_ip = "100.68.0.5"
  depends_on                = [aws_internet_gateway.Vpn-GW]
}

# 9. Create debian server and install/enable nginx
resource "aws_instance" "vpn-server" {
  ami = "ami-0588c11374527e516"
  instance_type = "t2.micro"

  tags = {
    Name = "Vpn Server"
  }
    depends_on = [aws_internet_gateway.Vpn-GW]
}
