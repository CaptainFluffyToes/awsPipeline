variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_pub_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdlEH1MlCX5yn5IzbjSH07ieBtpBMzNeNkYCI92Tyt0hyB+mnvK2VlA/Y2Nz00Vb5HsqPdmyEtoBPjo6CydMuCF/K92CoJ1HZh0tvT+7DciS3qyxlVLeppk4MkCGwMpQeaqkZTKKCDMVP/og727pT4tByFHxMaMooNQzASnVInKJIAyui2HBQ3fefK9l8nIpHg2tI1A6TiGwne5z6KPMAbx33rdW8IJAOmRPbNGyKL8MH2lOl9r/1Ha6TBlBVTasyDUGoYRn6DBgmapM+DfxCO13tUBfmhtAE23lvGLide0xc7AdxaoVAQrZ3M6bcnzBtBR5KVYR1MI5zyJPw5qzClFRNRpIobfB++rvGVChNo6ds0H2mYF4m3XRbZUg0INwz8cJnhDoJ/dBUsSPa5iWimP89lO11HW1Maj1/Q8qIU/V9j/hcXxmB9PtUSUK+nuhHZTQtPx60jg2Ej9PP7yT98bYgVOlPLPhuwoXcA50qXr2+Rns1rhWJ+iO6VntFddzE="
}

variable "aws_private_key" {
  type    = string
  default = "~/.ssh/cyberark_hydration"
}

variable "vpc_cidr" {
  type    = string
  default = "172.16.20.0/26"
}

variable "subnet_external_cidr" {
  type    = string
  default = "172.16.20.0/27"
}

variable "subnet_internal_cidr" {
  type    = string
  default = "172.16.20.32/27"
}

variable "name" {
  type    = string
  default = "cyberark_hydration"
}

variable "ansible_name" {
  type    = string
  default = "ansible"
}

variable "repo_name" {
  type    = string
  default = "conjur_policy"
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