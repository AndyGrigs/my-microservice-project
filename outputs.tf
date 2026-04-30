output "ecr_repository_url" {
  description = "ECR repository URL — use this in Jenkinsfile"
  value       = module.ecr.repository_url
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "nat_gateway_ip" {
  description = "NAT Gateway public IP — whitelist this in external services"
  value       = module.vpc.nat_gateway_ip
}

output "jenkins_password_command" {
  description = "Run this command to get Jenkins admin password"
  value       = module.jenkins.jenkins_admin_password_command
}

output "argocd_password_command" {
  description = "Run this command to get Argo CD initial admin password"
  value       = module.argo_cd.argocd_initial_password_command
}

output "argocd_url_command" {
  description = "Run this command to get Argo CD UI URL"
  value       = module.argo_cd.argocd_url_command
}

output "kubeconfig_command" {
  description = "Run this command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "rds_endpoint" {
  description = "Database connection endpoint"
  value       = module.rds.endpoint
}

output "rds_port" {
  description = "Database port"
  value       = module.rds.port
}

output "rds_db_name" {
  description = "Initial database name"
  value       = module.rds.db_name
}
