# ─── Загальні ───────────────────────────────────────────────────────────────

variable "project_name" {
  description = "Project name used for naming and tagging resources"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. production, staging)"
  type        = string
  default     = "production"
}

# ─── Перемикач Aurora / RDS ──────────────────────────────────────────────────

variable "use_aurora" {
  description = "If true — creates Aurora Cluster + writer instance. If false — creates a single aws_db_instance"
  type        = bool
  default     = false
}

# ─── Двигун БД ───────────────────────────────────────────────────────────────

variable "engine" {
  description = "Database engine: mysql | postgres | aurora-mysql | aurora-postgresql"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version (e.g. '15.4' for PostgreSQL, '8.0.mysql_aurora.3.04.0' for Aurora MySQL)"
  type        = string
  default     = "15.4"
}

variable "family" {
  description = "Parameter group family (e.g. postgres15, aurora-postgresql15, mysql8.0)"
  type        = string
  default     = "postgres15"
}

# ─── Інстанс ─────────────────────────────────────────────────────────────────

variable "instance_class" {
  description = "DB instance class (e.g. db.t3.medium, db.r6g.large)"
  type        = string
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  description = "Allocated storage in GB — used only when use_aurora = false"
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment — used only when use_aurora = false"
  type        = bool
  default     = false
}

# ─── Credentials та назва БД ─────────────────────────────────────────────────

variable "db_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

# ─── Мережа ──────────────────────────────────────────────────────────────────

variable "vpc_id" {
  description = "ID of the VPC where the database will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the DB Subnet Group (minimum 2 in different AZs)"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to the database port"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}
