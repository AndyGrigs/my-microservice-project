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

variable "chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "6.7.3"
}

variable "namespace" {
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "git_repo_url" {
  description = "Git repository URL that Argo CD will watch"
  type        = string
}

variable "git_repo_branch" {
  description = "Git branch that Argo CD will watch"
  type        = string
  default     = "main"
}

variable "app_namespace" {
  description = "Kubernetes namespace where Django app will be deployed"
  type        = string
  default     = "django-app"
}
