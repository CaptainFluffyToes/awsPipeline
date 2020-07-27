variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_pub_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/hR+nultsHekmpfJFAvwgy4SvcQfLQuSM8pBUChRFlzsh0pnvkt/YpgYojlbjKGDpmb9Ay5SFS0DEaj+c5qnIQw4SYrhWBmBLOgDToYD5fVayA4nAzhA5n5YyhBnMxbUAoOvyOj2XgEaIVRw23AtezWLB9CjijJusccVF+XQ6ChRJFLa92lCFXTORMk22+5ASW5Wcv6xdGwuLAnX8N0XMl6iY7ntRY0NemNYDAKLznonERywdopKC2UMsuQ/YlWna98md6SlcsAokRvSoWESK5DwcqYmeI2NKUrV7E/dtX1P2VQF6YJ5/nBUA2QKeYptruz1s1FdLhIb9a9ixW7I6irQz9hzIPebGUKaC1zS+31a5vlqAourzRUMhiIySXnHgJhnQCzGJQE0ApMaC+m2wC6L+lRLt2cUpvpOf7vokEVUUat4HbrhPEUWNNntgfrR8Kvm6nPyKiLu/1eniY7CMuXy9BCmHzxvkgUzqTTv4I6GvEChT+/bOjkqFYn+gjnk="
}

variable "vpc_cidr" {
  type    = string
  default = "172.86.21.0/26"
}

variable "subnet_external_cidr" {
  type    = string
  default = "172.86.21.0/27"
}

variable "subnet_internal_cidr" {
  type    = string
  default = "172.86.21.32/27"
}

variable "name" {
  type    = string
  default = "cyberark_demo"
}

variable "ansible_name" {
  type    = string
  default = "ansible"
}

variable "conjur_master_name" {
  type    = string
  default = "conjur_master"
}

variable "conjur_follower_name" {
  type    = string
  default = "conjur_follower"
}

variable "conjur_standby_name" {
  type    = string
  default = "conjur_standby"
}

variable "role" {
  type    = string
  default = "hydration"
}

variable "company" {
  type    = string
  default = "cyberark"
}

variable "ssh_key_name" {
  type    = string
  default = "hydration_access"
}

variable "conjur_master_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "conjur_standby_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "conjur_follower_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "master_instance_count" {
  type    = number
  default = 0
}

variable "standby_instance_count" {
  type    = number
  default = 0
}

variable "follower_instance_count" {
  type    = number
  default = 0
}

variable "ansible_ami" {
  type    = string
  default = "ami-06cf02a98a61f9f5e"
}

variable "ansible_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "local_cidr" {
  type    = string
  default = "71.184.77.90/32"
}