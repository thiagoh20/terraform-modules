# Security Group para RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS PostgreSQL instance"
  vpc_id      = var.vpc_id

  # En producción, RDS generalmente no necesita tráfico saliente
  egress {
    description = "No outbound traffic required for RDS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-rds-sg"
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group para Lambda
resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-${var.environment}-lambda-sg"
  description = "Security group for Lambda function to access RDS and Internet"
  vpc_id      = var.vpc_id

  # Permitir HTTPS para servicios AWS (API Gateway, CloudWatch, etc.)
  egress {
    description = "HTTPS to AWS services"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir DNS (UDP puerto 53) para resolución de nombres
  egress {
    description = "DNS resolution"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir HTTP para servicios que no usan HTTPS (opcional, solo si es necesario)
  # Descomenta si tu Lambda necesita hacer peticiones HTTP
  # egress {
  #   description = "HTTP to external services"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-lambda-sg"
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Regla de entrada para RDS: Permitir PostgreSQL desde Lambda
# Usamos un recurso separado para evitar dependencia circular
resource "aws_security_group_rule" "rds_ingress_from_lambda" {
  type                     = "ingress"
  description              = "PostgreSQL from Lambda"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lambda.id
  security_group_id        = aws_security_group.rds.id
}

# Regla de entrada para RDS: Permitir acceso desde IPs administrativas (opcional)
resource "aws_security_group_rule" "rds_ingress_from_admin" {
  count             = length(var.admin_cidr_blocks) > 0 ? length(var.admin_cidr_blocks) : 0
  type              = "ingress"
  description       = "PostgreSQL from admin IPs"
  from_port         = 5432
  to_port           = 5432
  protocol           = "tcp"
  cidr_blocks       = [var.admin_cidr_blocks[count.index]]
  security_group_id = aws_security_group.rds.id
}

# Regla de salida para Lambda: Permitir PostgreSQL hacia RDS
# Usamos un recurso separado para evitar dependencia circular
resource "aws_security_group_rule" "lambda_egress_to_rds" {
  type                     = "egress"
  description              = "PostgreSQL to RDS"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
  security_group_id        = aws_security_group.lambda.id
}
