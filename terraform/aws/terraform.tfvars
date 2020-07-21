region = "us-east-1"

aws_pub_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCLF5RUExiE8ZrTTKZN2bDYfE+ReRI1WIQmwTJFCfAH5tdngQEAKIG/M+xm2LJ4gNxh/0pQfZSimsULC+eJs8xnrkWZs1CnpoHiShub2GCJeaiNJAmjFrs3OFGcv0sGW+DK+WCoVLyendfDSWjGZ4psYFPwWOy8hRY9texkR6EokgttBZVmugZcPVLHnGv86lUFoaOj+PEHzxQpKU7CezkzGzlBUUA4S4J15Oe1k0YTLdZ+dUKAxHlyOmg+xse0Qy7/edCOz7GlwiS1gyrTab225LbVxB+ePUC1CjXG4DqEuP86fPsYJEZPZLze1o0uHLtX08OvO96VNorutKOj9DlX"

vpc_cidr = "172.86.21.0/26"

subnet_external_cidr = "172.86.21.0/27"

subnet_internal_cidr = "172.86.21.32/27"

name = "cyberark_hydration"

ansible_name = "ansible"

conjur_master_name = "conjur_master"

conjur_follower_name = "conjur_follower"

conjur_standby_name = "conjur_standby"

role = "hydration"

company = "cyberark"

ssh_key_name = "hydration_access"

conjur_master_instance_type = "t2.medium"

conjur_standby_instance_type = "t2.medium"

conjur_follower_instance_type = "t2.medium"

master_instance_count = 1

standby_instance_count = 2

follower_instance_count = 1

ansible_ami = "ami-06cf02a98a61f9f5e"

ansible_instance_type = "t2.medium"