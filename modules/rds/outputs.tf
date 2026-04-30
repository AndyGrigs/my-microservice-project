output "endpoint" {
  description = "Connection endpoint for the database (writer endpoint for Aurora)"
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address
}

output "port" {
  description = "Port the database is listening on"
  value = local.db_port
}

output "db_name" {
  description = "Name of the initial database"
  value = var.db_name
}

output "security_group_id" {
  description = "ID of the RDS security group"
  value = aws_security_group.rds.id
}

output "subnet_group_name" {
  description = "Name of the DB subnet group"
  value = aws_db_subnet_group.this.name
}

output "cluster_id" {
  description = "Aurora cluster identifier — empty string when use_aurora = false"
  value = var.use_aurora ? aws_rds_cluster.this[0].cluster_identifier : ""
}

output "instance_id" {
  description = "RDS instance identifier — empty string when use_aurora = true"
  value = var.use_aurora ? "" : aws_db_instance.this[0].identifier
}
