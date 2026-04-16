variable "vpc_name" {
  type    = string
  default = "main-vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_public_1_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "subnet_public_2_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "subnet_private_1_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "subnet_private_2_cidr" {
  type    = string
  default = "10.0.4.0/24"
}