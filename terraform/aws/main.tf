provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "cyberark_hydration" {
  cidr_block = "172.86.21.0/26"

  tags = {
    "Name" = "cyberark_hydration",
    "CyberArk" = "Hydration"
  }
}

resource "aws_internet_gateway" "cyberark_hydration" {
  vpc_id = aws_vpc.cyberark_hydration.id

  tags = {
    "Cyberark" = "Hydration",
    "Name" = "cyberark_hydration"
  }
}

resource "aws_eip" "cyberark_hydration" {
  vpc      = true

  tags = {
    "Cyberark" = "Hydration",
    "Name" = "cyberark_hydration"
  }
}

resource "aws_subnet" "cyberark_hydration_external" {
  vpc_id     = aws_vpc.cyberark_hydration.id
  cidr_block = "172.86.21.0/27"
  map_public_ip_on_launch = true

  tags = {
    "Cyberark" = "Hydration",
    "Name" = "cyberark_hydration_external"
  }

  depends_on = [aws_internet_gateway.cyberark_hydration]
}

resource "aws_subnet" "cyberark_hydration_internal" {
  vpc_id     = aws_vpc.cyberark_hydration.id
  cidr_block = "172.86.21.32/27"
  map_public_ip_on_launch = false

  tags = {
    "Cyberark" = "Hydration",
    "Name" = "cyberark_hydration_internal"
  }

  depends_on = [aws_internet_gateway.cyberark_hydration]
}

resource "aws_nat_gateway" "cyberark_hydration" {
  allocation_id = aws_eip.cyberark_hydration.id
  subnet_id     = aws_subnet.cyberark_hydration_external.id

  tags = {
    "Cyberark" = "Hydration",
    "Name" = "cyberark_hydration"
  }
}

resource "aws_route_table" "cyberark_hydration_external" {
  vpc_id = aws_vpc.cyberark_hydration.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cyberark_hydration.id
  }

  tags = {
  "Name" = "cyberark_hydration_external",
  "CyberArk" = "Hydration"
  }
}

resource "aws_route_table" "cyberark_hydration_internal" {
  vpc_id = aws_vpc.cyberark_hydration.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cyberark_hydration.id
  }

  tags = {
  "Name" = "cyberark_hydration_internal",
  "CyberArk" = "Hydration"
  }
}

resource "aws_route_table_association" "cyberark_hydration_internal" {
  subnet_id      = aws_subnet.cyberark_hydration_internal.id
  route_table_id = aws_route_table.cyberark_hydration_internal.id
}

resource "aws_route_table_association" "cyberark_hydration_external" {
  subnet_id      = aws_subnet.cyberark_hydration_external.id
  route_table_id = aws_route_table.cyberark_hydration_external.id
}

resource "aws_security_group" "cyberark_hydration" {
  name        = "cyberark_hydration"
  description = "Allow traffic for Cyberark environment"
  vpc_id      = aws_vpc.cyberark_hydration.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.cyberark_hydration.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
  "Name" = "cyberark_hydration",
  "CyberArk" = "Hydration"
  }
}

resource "aws_launch_template" "docker_nodes" {
  name = "docker_nodes"
  description = "This will install docker on amazon linux 2 machines. It will also install python3 and pip3."
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 30
      delete_on_termination = true
      volume_type = "standard"
    }
  }
  image_id = "ami-09d95fab7fff3776c"
  instance_type = "t2.medium"
  key_name = "dk-master"
  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "optional"
  }
  network_interfaces {
    delete_on_termination = true
    security_groups = [aws_security_group.cyberark_hydration.id]
    subnet_id = aws_subnet.cyberark_hydration_internal.id
  }

  user_data = filebase64("${path.module}/user_data.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      "role" = "conjur",
      "clusterrole" = "leader",
      "CyberArk" = "Hydration"
    }
  }
}