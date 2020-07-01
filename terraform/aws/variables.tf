variable "region" {
  type    = string
  default = "us-east-1"
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

variable "aws_key_name" {
  type    = string
  default = "dk-master"
}

variable "name" {
  type    = string
  default = "cyberark_demo"
}

variable "role" {
  type    = string
  default = "hydration"
}

variable "company" {
  type    = string
  default = "cyberark"
}