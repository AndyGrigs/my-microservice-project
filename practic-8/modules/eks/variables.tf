variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "django-cluster"
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS"
  type        = list(string)
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}