variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-locks"
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "eu-west-1"
}
