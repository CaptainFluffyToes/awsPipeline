region = "us-east-1"

aws_pub_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdlEH1MlCX5yn5IzbjSH07ieBtpBMzNeNkYCI92Tyt0hyB+mnvK2VlA/Y2Nz00Vb5HsqPdmyEtoBPjo6CydMuCF/K92CoJ1HZh0tvT+7DciS3qyxlVLeppk4MkCGwMpQeaqkZTKKCDMVP/og727pT4tByFHxMaMooNQzASnVInKJIAyui2HBQ3fefK9l8nIpHg2tI1A6TiGwne5z6KPMAbx33rdW8IJAOmRPbNGyKL8MH2lOl9r/1Ha6TBlBVTasyDUGoYRn6DBgmapM+DfxCO13tUBfmhtAE23lvGLide0xc7AdxaoVAQrZ3M6bcnzBtBR5KVYR1MI5zyJPw5qzClFRNRpIobfB++rvGVChNo6ds0H2mYF4m3XRbZUg0INwz8cJnhDoJ/dBUsSPa5iWimP89lO11HW1Maj1/Q8qIU/V9j/hcXxmB9PtUSUK+nuhHZTQtPx60jg2Ej9PP7yT98bYgVOlPLPhuwoXcA50qXr2+Rns1rhWJ+iO6VntFddzE="

aws_private_key = "~/.ssh/cyberark_hydration"

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

local_cidr = "71.184.77.90/32"