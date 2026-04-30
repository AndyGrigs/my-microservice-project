resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = "${local.name_prefix}-aurora"

  engine         = var.engine
  engine_version = var.engine_version

  database_name   = var.db_name
  master_username = var.db_username
  master_password = var.db_password
  port            = local.db_port

  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.rds.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false
  storage_encrypted       = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora"
  })
}

resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? 1 : 0

  identifier         = "${local.name_prefix}-aurora-writer"
  cluster_identifier = aws_rds_cluster.this[0].id

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_subnet_group_name = aws_db_subnet_group.this.name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-aurora-writer"
    Role = "writer"
  })
}
