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

# ─── RDS ─────────────────────────────────────────────────────────────────────

variable "rds_use_aurora" {
  description = "If true — creates Aurora Cluster. If false — creates a single RDS instance"
  type        = bool
  default     = false
}

variable "rds_engine" {
  description = "Database engine: postgres | mysql | aurora-postgresql | aurora-mysql"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "Database engine version (e.g. '15.4' for PostgreSQL)"
  type        = string
  default     = "15.4"
}

variable "rds_family" {
  description = "Parameter group family (e.g. postgres15, aurora-postgresql15, mysql8.0)"
  type        = string
  default     = "postgres15"
}

variable "rds_instance_class" {
  description = "DB instance class (e.g. db.t3.medium)"
  type        = string
  default     = "db.t3.medium"
}

variable "rds_db_name" {
  description = "Name of the initial database"
  type        = string
  default     = "appdb"
}

variable "rds_db_username" {
  description = "Master username for the database"
  type        = string
  default     = "dbadmin"
}

variable "rds_db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}
