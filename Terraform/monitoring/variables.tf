# variables.tf

variable "aws_region" {
  description = "AWS регіон для розгортання ресурсів"
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Ім'я EC2 інстансу"
  default     = "monitoring server"
}

variable "instance_type" {
  description = "Тип EC2 інстансу"
  default     = "t2.small"
}

variable "key_pair_name" {
  description = "Назва існуючого Key Pair для SSH доступу"
  default    = "aws"   
}

variable "vpc_id" {
  description = "ID VPC, в якому буде розгорнутий інстанс"
  default     = "vpc-0f3ec9d117e30186a"
}

variable "subnet_id" {
  description = "ID підмережі, в якій буде розгорнутий інстанс"
  default     = "subnet-0a89e035964ec5113"
}

variable "allowed_ssh_cidr" {
  description = "CIDR блок для дозволу SSH доступу"
  default     = "0.0.0.0/0" 
}

variable "volume_size" {
  description = "Розмір сховища інстансу в GB"
  default     = 30
}
