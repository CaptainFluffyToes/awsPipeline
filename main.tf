terraform {
  backend "remote" {
    # The name of your Terraform Cloud organization.
    organization = "captainfluffytoes"

    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "awsPipeline"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_key_pair" "deployer" {
  key_name   = var.ssh_key_name
  public_key = file("~/.ssh/id_rsa.pub")
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
    Name    = join("_", [var.name, "external"]),
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
    Name    = join("_", [var.name, "internal"]),
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
    Name    = join("_", [var.name, "external"]),
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
    Name    = join("_", [var.name, "internal"]),
    role    = var.role,
    company = var.company
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

resource "aws_security_group" "cyberark_sg" {
  name        = "cyberark_hydration"
  description = "Allow traffic for Cyberark environment"
  vpc_id      = aws_vpc.cyberark_vpc.id

  ingress {
    description = "Everything from external subnet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.subnet_external_cidr]
  }

  ingress {
    description = "SSH from Local IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.local_cidr]
  }

  ingress {
    description = "HTTPS from Local IP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.local_cidr]
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
    device_name = "/dev/xvda"
    ebs {
      volume_size = 40
    }
  }
  image_id      = "ami-09d95fab7fff3776c"
  instance_type = "t2.medium"
  key_name      = var.ssh_key_name
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
  network_interfaces {
    delete_on_termination = true
    security_groups       = [aws_security_group.cyberark_sg.id]
    subnet_id             = aws_subnet.cyberark_internal.id
  }

  user_data = filebase64("${path.module}/userdata/base_configuration.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = var.name,
      role    = var.role,
      company = var.company
    }
  }
}

resource "aws_launch_template" "conjur_master" {
  name        = "conjur_master"
  description = "This will install docker and then configure a conjur master"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 40
    }
  }
  image_id      = "ami-09d95fab7fff3776c"
  instance_type = var.conjur_master_instance_type
  key_name      = var.ssh_key_name
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
  network_interfaces {
    delete_on_termination = true
    security_groups       = [aws_security_group.cyberark_sg.id]
    subnet_id             = aws_subnet.cyberark_internal.id
  }

  user_data = filebase64("${path.module}/userdata/base_configuration.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = join("_", [var.name, var.conjur_master_name]),
      role        = var.role,
      company     = var.company,
      clusterrole = "leader"
    }
  }
}

resource "aws_launch_template" "conjur_standbys" {
  name        = "conjur_standbys"
  description = "This will install docker and then start up a standby conjur instance"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 40
    }
  }
  image_id      = "ami-09d95fab7fff3776c"
  instance_type = var.conjur_standby_instance_type
  key_name      = var.ssh_key_name
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
  network_interfaces {
    delete_on_termination = true
    security_groups       = [aws_security_group.cyberark_sg.id]
    subnet_id             = aws_subnet.cyberark_internal.id
  }

  user_data = filebase64("${path.module}/userdata/base_configuration.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = join("_", [var.name, var.conjur_standby_name]),
      role        = var.role,
      company     = var.company,
      clusterrole = "standby"
    }
  }
}

resource "aws_launch_template" "conjur_followers" {
  name        = "conjur_followers"
  description = "This will install docker and then start up a follower"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 40
    }
  }
  image_id      = "ami-09d95fab7fff3776c"
  instance_type = var.conjur_follower_instance_type
  key_name      = var.ssh_key_name
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
  network_interfaces {
    delete_on_termination = true
    security_groups       = [aws_security_group.cyberark_sg.id]
    subnet_id             = aws_subnet.cyberark_internal.id
  }

  user_data = filebase64("${path.module}/userdata/base_configuration.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = join("_", [var.name, var.conjur_follower_name]),
      role        = var.role,
      company     = var.company,
      clusterrole = "follower"
    }
  }
}

resource "aws_autoscaling_group" "conjur_master" {
  desired_capacity = var.master_instance_count
  max_size         = var.master_instance_count
  min_size         = 0

  launch_template {
    id      = aws_launch_template.conjur_master.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "conjur_standbys" {
  desired_capacity = var.standby_instance_count
  max_size         = var.standby_instance_count
  min_size         = 0

  launch_template {
    id      = aws_launch_template.conjur_standbys.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "conjur_followers" {
  desired_capacity = var.follower_instance_count
  max_size         = var.follower_instance_count
  min_size         = 0

  launch_template {
    id      = aws_launch_template.conjur_followers.id
    version = "$Latest"
  }
}

resource "aws_instance" "ansible_tower" {
  ami           = var.ansible_ami
  instance_type = var.ansible_instance_type
  key_name      = var.ssh_key_name

  root_block_device {
    delete_on_termination = true
    volume_size           = 40
    volume_type           = "standard"
  }

  subnet_id        = aws_subnet.cyberark_external.id
  security_groups  = [aws_security_group.cyberark_sg.id]
  user_data_base64 = filebase64("${path.module}/userdata/install_ansible.sh")

  tags = {
    Name        = join("_", [var.name, var.ansible_name]),
    role        = var.role,
    company     = var.company,
    clusterrole = "ansible"
  }
}