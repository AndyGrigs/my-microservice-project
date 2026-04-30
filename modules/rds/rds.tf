resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1

  identifier = "${local.name_prefix}-rds"

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = local.db_port

  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.this[0].name

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds"
  })
}
