region = "us-east-1"

aws_pub_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6Pq8eTCKct2pOJ/ocfQkJGonYnmmqo0tk3O2/KmlPixV6zXfonfbq3kYMSePjI7JpH6GU3pHR5MwWMxatvOgOASdsiiNYFK6Az+0LPCYJFRbYOuw9CVgXE87YELdZPYrnw+PnheYi1GuRFuuZiRV1VCMH0WIlsADla3f/8YKQVB0rDRPygCsfXX+CWN34k+SK6Ufkhysa2LBQAyjcPNosKB5DtaNp2vbwi7q/30NV8QpZA3H66msCymSUZLiOBQrysvBu2uZqmL+GB4ICedZm/CfK1HHLRptuDCnKv7MTt5H/iv3hqoxcb/mpLMxQq8dPwJABzxWA6UQ3VJbHYOgz"

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