variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "eu-west-3"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.128.0/20", "10.0.144.0/20"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19"]
}
variable "database_subnets" {
  description = "List of database subnets"
  type        = list(string)
  default     = ["10.0.64.0/19", "10.0.96.0/19"]  # Utilisez des CIDR uniques ici
}
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "wordpress-eks-cluster"
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes for the EKS cluster"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of worker nodes for the EKS cluster"
  type        = number
  default     = 3
}

variable "min_capacity" {
  description = "Minimum number of worker nodes for the EKS cluster"
  type        = number
  default     = 1
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password for the RDS database"
  default     = "adminDatascientest"
  type        = string
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
  default     = "wordpress"
}

variable "db_instance_class" {
  description = "Instance class for the RDS database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS database (in GB)"
  type        = number
  default     = 20
}
variable "access_key" {
  description = "AWS Access Key"
  default     = ""

}
variable "secret_key" {
  description = "AWS Secret Key"
  default     = ""
}
variable "AWS_userName" {
  description = "AWS userName"
  default     = " "
}
variable "key_name" {
  default = "maysa_keypair"
  type    = string
}
