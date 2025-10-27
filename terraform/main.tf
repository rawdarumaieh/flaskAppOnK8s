/* 
I divided this file into two sections, the first is for the *vpc* aka network module
while the second is for the EKS cluster definition 
*/
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"

  cidr = var.vpc_cidr

  #deploying the infrastructure over two availability zones and as they are two azs i only need 2 subnets

  azs             = ["${var.region}a", "${var.region}b"]

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  # enabling private subnets to initiate outbound connection to internet
  enable_nat_gateway = true

}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  

  cluster_name    = var.cluster_name
  cluster_version = "1.30" 
  cluster_endpoint_public_access = true
  
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets 
  control_plane_subnet_ids = module.vpc.private_subnets

  // Worker Nodes Configuration 
  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_types = [var.instance_type]
      // Enabling EKS security groups to allow traffic from the VPC
      vpc_security_group_ids = [module.vpc.default_security_group_id]
    }
  }

  
  

  // Tags for AWS resources
  tags = {
    # I know that i am making a "mock production scenario but I am using dev for cost management and polices complications"
    Environment = "Dev"
    Project     = "EKS-Cluster"
  }
}

# Creating  Access Entry to link IAM user to EKS RBAC system
resource "aws_eks_access_entry" "k8s_admin_entry" {
  cluster_name  = var.cluster_name
  principal_arn = "arn:aws:iam::162444186117:user/terraform-eks" 
  user_name     = "kubernetes-admin-username"
  type          = "STANDARD"
}

# 2. Associating the Policy to grant the full cluster-admin permissions
resource "aws_eks_access_policy_association" "k8s_admin_policy" {
  cluster_name  = aws_eks_access_entry.k8s_admin_entry.cluster_name
  principal_arn = aws_eks_access_entry.k8s_admin_entry.principal_arn
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  
  access_scope {
    type = "cluster"
  }
}