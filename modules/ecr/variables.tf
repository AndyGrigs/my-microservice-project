variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
}

variable "image_retention_days" {
  description = "Number of days to keep untagged images"
  type        = number
  default     = 30
}
