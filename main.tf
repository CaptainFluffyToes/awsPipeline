# terraform {
#   backend "remote" {
#     organization = "captainfluffytoes"
#     workspaces {
#       name = "awsPipeline"
#     }
#   }
# }

#aws provider
provider "aws" {
  region = var.region
}

#creates keypair used by all of the instances that will be created
resource "aws_key_pair" "deployer" {
  key_name   = var.ssh_key_name
  public_key = var.aws_pub_key
}

#create VPC specific for demo environment
resource "aws_vpc" "cyberark_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = var.name,
    role    = var.role,
    company = var.company
  }
}

#create internet gateway specific for demo environment
resource "aws_internet_gateway" "cyberark_igw" {
  vpc_id = aws_vpc.cyberark_vpc.id

  tags = {
    Name    = var.name,
    role    = var.role,
    company = var.company
  }

  depends_on = [aws_vpc.cyberark_vpc]
}

#assign an elastic IP for demo environment external access
resource "aws_eip" "cyberark_eip" {
  vpc = true

  tags = {
    Name    = var.name,
    role    = var.role,
    company = var.company
  }

  depends_on = [aws_vpc.cyberark_vpc]
}

#create a subnet for instances to get external internet access. This automatically assigns an EIP to the instance
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

#create nat gateway for private instances
resource "aws_nat_gateway" "cyberark_ngw" {
  allocation_id = aws_eip.cyberark_eip.id
  subnet_id     = aws_subnet.cyberark_external.id

  tags = {
    Name    = var.name,
    role    = var.role,
    company = var.company
  }

  depends_on = [aws_subnet.cyberark_external]
}


#create a subnet for internal communication
resource "aws_subnet" "cyberark_internal" {
  vpc_id                  = aws_vpc.cyberark_vpc.id
  cidr_block              = var.subnet_internal_cidr
  map_public_ip_on_launch = false

  tags = {
    Name    = join("_", [var.name, "internal"]),
    role    = var.role,
    company = var.company
  }

  depends_on = [aws_nat_gateway.cyberark_ngw]
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

  depends_on = [aws_internet_gateway.cyberark_igw]
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

  depends_on = [aws_nat_gateway.cyberark_ngw]
}

resource "aws_route_table_association" "ca_route_internal" {
  subnet_id      = aws_subnet.cyberark_internal.id
  route_table_id = aws_route_table.cyberark_route_internal.id

  depends_on = [aws_subnet.cyberark_internal, aws_route_table.cyberark_route_internal]
}

resource "aws_route_table_association" "ca_route_external" {
  subnet_id      = aws_subnet.cyberark_external.id
  route_table_id = aws_route_table.cyberark_route_external.id

  depends_on = [aws_subnet.cyberark_external, aws_route_table.cyberark_route_external]
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

  depends_on = [aws_vpc.cyberark_vpc]
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

  user_data = filebase64("${path.module}/files/userdata/base_configuration.sh")

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

  user_data = filebase64("${path.module}/files/userdata/base_configuration.sh")

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

  user_data = filebase64("${path.module}/files/userdata/base_configuration.sh")

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

  user_data = filebase64("${path.module}/files/userdata/base_configuration.sh")

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

resource "aws_iam_policy" "ansible_access_policy" {
  name        = join("_", [var.name, "policy"])
  path        = "/"
  description = "This policy allows ansible to see the rest of the instances"
  policy      = file("${path.module}/files/iam/ec2access.json")
}

resource "aws_iam_role" "ansible_access_role" {
  name                  = join("_", [var.name, "role"])
  assume_role_policy    = file("${path.module}/files/iam/assumerolepolicy.json")
  force_detach_policies = true

  tags = {
    Name    = join("_", [var.name, "role"]),
    role    = var.role,
    company = var.company
  }
}

resource "aws_iam_role_policy_attachment" "ansible_role_policy_attachment" {
  role       = aws_iam_role.ansible_access_role.name
  policy_arn = aws_iam_policy.ansible_access_policy.arn

  depends_on = [
    aws_iam_role.ansible_access_role,
    aws_iam_policy.ansible_access_policy
  ]
}

resource "aws_iam_instance_profile" "ansible_profile" {
  name = join("_", [var.name, "profile"])
  role = aws_iam_role.ansible_access_role.name

  depends_on = [aws_iam_role_policy_attachment.ansible_role_policy_attachment]
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

  subnet_id            = aws_subnet.cyberark_external.id
  security_groups      = [aws_security_group.cyberark_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ansible_profile.name
  user_data_base64     = filebase64("${path.module}/files/userdata/install_ansible.sh")

  tags = {
    Name        = join("_", [var.name, var.ansible_name]),
    role        = var.role,
    company     = var.company,
    clusterrole = "ansible"
  }

  provisioner "file" {
    source      = var.aws_private_key
    destination = "~/aws"

    connection {
      type        = "ssh"
      user        = "centos"
      host        = self.public_ip
      private_key = file(var.aws_private_key)
    }
  }

  depends_on = [
    aws_subnet.cyberark_external,
    aws_security_group.cyberark_sg,
    aws_iam_instance_profile.ansible_profile
  ]
}

resource "aws_codecommit_repository" "conjur_policy" {
  repository_name = "conjur_policy"
  description     = "This repo holds all of the conjur policy"

  tags = {
    Name        = join("_", [var.name, var.repo_name]),
    role        = var.role,
    company     = var.company,
    clusterrole = "policy"
  }
}