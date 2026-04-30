locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Порт визначається автоматично на основі engine
  db_port = can(regex("mysql", var.engine)) ? 3306 : 5432

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ─── DB Subnet Group ─────────────────────────────────────────────────────────

resource "aws_db_subnet_group" "this" {
  name        = "${local.name_prefix}-rds-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Subnet group for ${local.name_prefix} RDS"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds-subnet-group"
  })
}

# ─── Security Group ───────────────────────────────────────────────────────────

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Allow inbound traffic to RDS on port ${local.db_port}"
  vpc_id      = var.vpc_id

  ingress {
    description = "DB access from allowed CIDRs"
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds-sg"
  })
}

# ─── Parameter Group (звичайна RDS instance) ─────────────────────────────────

resource "aws_db_parameter_group" "this" {
  count = var.use_aurora ? 0 : 1

  name        = "${local.name_prefix}-rds-pg"
  family      = var.family
  description = "Parameter group for ${local.name_prefix} RDS"

  parameter {
    name  = "max_connections"
    value = "200"
  }

  # log_statement та work_mem підтримуються лише PostgreSQL
  dynamic "parameter" {
    for_each = can(regex("postgres", var.family)) ? [1] : []
    content {
      name  = "log_statement"
      value = "all"
    }
  }

  dynamic "parameter" {
    for_each = can(regex("postgres", var.family)) ? [1] : []
    content {
      name  = "work_mem"
      value = "16384" # 16 MB в кілобайтах
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds-pg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ─── Parameter Group (Aurora Cluster) ────────────────────────────────────────

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.use_aurora ? 1 : 0

  name        = "${local.name_prefix}-aurora-cpg"
  family      = var.family
  description = "Cluster parameter group for ${local.name_prefix} Aurora"

  parameter {
    name  = "max_connections"
    value = "200"
  }

  dynamic "parameter" {
    for_each = can(regex("postgres", var.family)) ? [1] : []
    content {
      name  = "log_statement"
      value = "all"
    }
  }

  dynamic "parameter" {
    for_each = can(regex("postgres", var.family)) ? [1] : []
    content {
      name  = "work_mem"
      value = "16384"
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-cpg"
  })

  lifecycle {
    create_before_destroy = true
  }
}
