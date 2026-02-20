# Subnet Group para RDS
# Usamos un hash de las subredes en el nombre para forzar recreación cuando cambian
locals {
  subnet_hash = substr(md5(join(",", var.subnet_ids)), 0, 8)
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group-${local.subnet_hash}"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-db-subnet-group"
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-db"

  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage  = var.db_max_allocated_storage
  storage_type          = var.db_storage_type
  storage_encrypted     = var.db_storage_encrypted
  kms_key_id            = var.db_kms_key_id

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [var.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  publicly_accessible    = var.db_publicly_accessible
  multi_az               = var.db_multi_az

  backup_retention_period = var.db_backup_retention_period
  backup_window           = var.db_backup_window
  maintenance_window      = var.db_maintenance_window
  copy_tags_to_snapshot   = true

  skip_final_snapshot       = var.db_skip_final_snapshot
  final_snapshot_identifier = var.db_skip_final_snapshot ? null : "${var.project_name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  deletion_protection = var.db_deletion_protection

  # Monitoreo y logging
  enabled_cloudwatch_logs_exports = var.db_enabled_cloudwatch_logs_exports
  monitoring_interval             = var.db_monitoring_interval
  monitoring_role_arn             = var.db_monitoring_interval > 0 ? var.db_monitoring_role_arn : null
  performance_insights_enabled     = var.db_performance_insights_enabled
  performance_insights_retention_period = var.db_performance_insights_enabled ? var.db_performance_insights_retention_period : null

  # Parámetros de base de datos
  parameter_group_name = var.db_parameter_group_name

  # Auto minor version upgrade
  auto_minor_version_upgrade = var.db_auto_minor_version_upgrade

  # Aplicar cambios inmediatamente
  apply_immediately = var.db_apply_immediately

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-db"
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  )

  lifecycle {
    # Forzar recreación cuando cambia el DB Subnet Group
    # AWS no permite mover una instancia RDS entre DB Subnet Groups mediante modificación
    replace_triggered_by = [
      aws_db_subnet_group.main.id
    ]
    create_before_destroy = true
    ignore_changes = [
      # Ignorar cambios en password si se gestiona externamente
      password,
      # Ignorar cambios en final_snapshot_identifier para evitar recreaciones
      final_snapshot_identifier,
    ]
  }
}
