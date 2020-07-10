variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_pub_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCLF5RUExiE8ZrTTKZN2bDYfE+ReRI1WIQmwTJFCfAH5tdngQEAKIG/M+xm2LJ4gNxh/0pQfZSimsULC+eJs8xnrkWZs1CnpoHiShub2GCJeaiNJAmjFrs3OFGcv0sGW+DK+WCoVLyendfDSWjGZ4psYFPwWOy8hRY9texkR6EokgttBZVmugZcPVLHnGv86lUFoaOj+PEHzxQpKU7CezkzGzlBUUA4S4J15Oe1k0YTLdZ+dUKAxHlyOmg+xse0Qy7/edCOz7GlwiS1gyrTab225LbVxB+ePUC1CjXG4DqEuP86fPsYJEZPZLze1o0uHLtX08OvO96VNorutKOj9DlX"
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
  type = string
  default = "ansible"
}

variable "conjur_master_name" {
  type = string
  default = "conjur_master"
}

variable "conjur_follower_name" {
  type = string
  default = "conjur_follower"
}

variable "conjur_standby_name" {
  type = string
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
  default = "dk-master"
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

variable "standby_instance_count" {
  type    = number
  default = 2
}

variable "follower_instance_count" {
  type    = number
  default = 1
}

variable "ansible_ami" {
  type    = string
  default = "ami-037c4c158e6e397eb"
}

variable "ansible_instance_type" {
  type    = string
  default = "t2.medium"
}