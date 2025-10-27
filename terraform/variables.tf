#Defining the variables i need for configuartions 
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "terraform-eks-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  #choosing a relativly small instance matching the size of deployed application
  default     = "t3.micro"
}

