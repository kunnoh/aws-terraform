# Provision and configure an AWS EC2 instance using Terraform & Ansible

## Prerequsistes
- AWS account
- AWS CLI
- Terraform
- Ansible
- Text editor(VSCode)

## Create new user in AWS and configure AWS CLI
One you create a new user on AWS, you should create a new user to play with. Don't use root account when it's not required. Create a new IAM user that has admin access.

*Done*:
1. Create vpc
2. Create Internet Gateway
3. Create Custom Route Table
4. Create a Subnet
5. Associate subnet with Route Table
6. Create Security Group to allow port 22,80,443
7. Create a network interface with an ip in the subnet that was created in step 4
8. Assign an elastic IP to the network interface created in step 7
9. Create debian server and install/enable apache2,nginx


## Reference
- [Terraform aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)

- [Terraform aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)

- [Terraform aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)

- [Terraform aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

- [Terraform aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)

- [Terreform aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)

- []()
