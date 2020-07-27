region = "us-east-1"

aws_pub_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/hR+nultsHekmpfJFAvwgy4SvcQfLQuSM8pBUChRFlzsh0pnvkt/YpgYojlbjKGDpmb9Ay5SFS0DEaj+c5qnIQw4SYrhWBmBLOgDToYD5fVayA4nAzhA5n5YyhBnMxbUAoOvyOj2XgEaIVRw23AtezWLB9CjijJusccVF+XQ6ChRJFLa92lCFXTORMk22+5ASW5Wcv6xdGwuLAnX8N0XMl6iY7ntRY0NemNYDAKLznonERywdopKC2UMsuQ/YlWna98md6SlcsAokRvSoWESK5DwcqYmeI2NKUrV7E/dtX1P2VQF6YJ5/nBUA2QKeYptruz1s1FdLhIb9a9ixW7I6irQz9hzIPebGUKaC1zS+31a5vlqAourzRUMhiIySXnHgJhnQCzGJQE0ApMaC+m2wC6L+lRLt2cUpvpOf7vokEVUUat4HbrhPEUWNNntgfrR8Kvm6nPyKiLu/1eniY7CMuXy9BCmHzxvkgUzqTTv4I6GvEChT+/bOjkqFYn+gjnk="

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