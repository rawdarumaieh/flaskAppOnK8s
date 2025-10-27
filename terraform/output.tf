# Since i am going to configure kubectl i thought to retrieve imp information needed to for it 

output "cluster_endpoint" {
  description = "endpoint for the EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "the name of the EKS cluster"
  value       = module.eks.cluster_id
}