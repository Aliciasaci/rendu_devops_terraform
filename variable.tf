variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_ami" {
  description = "AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "vm_user" {
  description = "user of the vm"
  type        = string
}

variable "keypair_name" {
  description = "value of ssh key"
  type        = string
}

variable "instance_name" {
  description = "Name for the instance"
  type        = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "value of the secret key"
  type        = string
}

variable "AWS_ACCESS_KEY_ID" {
  description = "value of the access key"
  type        = string
}
