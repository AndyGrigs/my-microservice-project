variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name used for naming and tagging resources"
  type        = string
  default     = "django-cicd"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
}

variable "git_repo_url" {
  description = "SSH URL of the Git repository"
  type        = string
}
