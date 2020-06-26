provider "aws" {
  region = var.region
}

resource "aws_vpc" "cyberark_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name    = var.name,
    role    = var.role,
    company = var.company
  }
}

resource "aws_internet_gateway" "cyberark_igw" {
  vpc_id = aws_vpc.cyberark_vpc.id

  tags = {
    Name    = var.name,
    role    = var.role,
    company = var.company
  }
}

resource "aws_eip" "cyberark_eip" {
  vpc = true

  tags = {
    Name    = var.name,
    role    = var.role,
    company = var.company
  }
}

resource "aws_subnet" "cyberark_external" {
  vpc_id                  = aws_vpc.cyberark_vpc.id
  cidr_block              = var.subnet_external_cidr
  map_public_ip_on_launch = true

  tags = {
    Name    = var.name,
    role    = var.role,
    company = var.company
  }

  depends_on = [aws_internet_gateway.cyberark_igw]
}

resource "aws_subnet" "cyberark_internal" {
  vpc_id                  = aws_vpc.cyberark_vpc.id
  cidr_block              = var.subnet_internal_cidr
  map_public_ip_on_launch = false

  tags = {
    Name    = var.name,
    role    = var.role,
    company = var.company
  }

  depends_on = [aws_internet_gateway.cyberark_igw]
}

resource "aws_nat_gateway" "cyberark_ngw" {
  allocation_id = aws_eip.cyberark_eip.id
  subnet_id     = aws_subnet.cyberark_external.id

  tags = {
    Name    = var.name,
    role    = var.role,
    company = var.company
  }
}

resource "aws_route_table" "cyberark_route_external" {
  vpc_id = aws_vpc.cyberark_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cyberark_igw.id
  }

  tags = {
    Name    = var.name,
    role    = var.role,
    company = var.company
  }
}

resource "aws_route_table" "cyberark_route_internal" {
  vpc_id = aws_vpc.cyberark_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cyberark_ngw.id
  }

  tags = {
    "CyberArk" = "Hydration"
  }
}

resource "aws_route_table_association" "ca_route_internal" {
  subnet_id      = aws_subnet.cyberark_internal.id
  route_table_id = aws_route_table.cyberark_route_internal.id
}

resource "aws_route_table_association" "ca_route_external" {
  subnet_id      = aws_subnet.cyberark_external.id
  route_table_id = aws_route_table.cyberark_route_external.id
}

resource "aws_security_group" "cyberark_hydration" {
  name        = "cyberark_hydration"
  description = "Allow traffic for Cyberark environment"
  vpc_id      = aws_vpc.cyberark_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.cyberark_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"     = "cyberark_hydration",
    "CyberArk" = "Hydration"
  }
}

resource "aws_launch_template" "docker_nodes" {
  name        = "docker_nodes"
  description = "This will install docker on amazon linux 2 machines. It will also install python3 and pip3."
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 30
      delete_on_termination = true
      volume_type           = "standard"
    }
  }
  image_id      = "ami-09d95fab7fff3776c"
  instance_type = "t2.medium"
  key_name      = "dk-master"
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
  network_interfaces {
    delete_on_termination = true
    security_groups       = [aws_security_group.cyberark_hydration.id]
    subnet_id             = aws_subnet.cyberark_internal.id
  }

  user_data = filebase64("${path.module}/user_data.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = var.name,
      role    = var.role,
      company = var.company
    }
  }
}