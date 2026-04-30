variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  type        = string
}

variable "cluster_ca" {
  description = "Base64 encoded certificate authority data"
  type        = string
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
}

variable "chart_version" {
  description = "Jenkins Helm chart version"
  type        = string
  default     = "5.1.0"
}

variable "namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "git_repo_url" {
  description = "Git repository URL that Jenkins will update (helm values repo)"
  type        = string
}
