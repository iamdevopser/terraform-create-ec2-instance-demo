terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_instance" "Terraform-Demo" {
  ami = "ami-052efd3df9dad4825"
  instance_type = "t2.micro" 
  key_name = "tarik"
  tags = {
    Name = "TerraformDemo"
  }
}

resource "aws_eip" "eip" {
  instance = aws_instance.Terraform-Demo.id
  vpc      = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.Subnet_A.id
  tags = {
    Name = "nat_gw"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "igw"
  }
}
resource "aws_subnet" "Subnet_A" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Subnet_A"
  }
}

resource "aws_subnet" "Subnet_B" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "Subnet_B"
  }
}



resource "aws_security_group" "tf-demo-sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.tf_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.tf_vpc.cidr_block]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.tf_vpc.cidr_block]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.tf_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-demo-sg"
  }
}

