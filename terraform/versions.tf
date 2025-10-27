#Defining the required Terraform providers which is in this case AWS and K8s
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "aws" {
  region = var.region
}



/* since i am destorying everything after i done 
i though there was no need to configure s3 bucket to store the terraform status in.
this is surely not the best practice*/


