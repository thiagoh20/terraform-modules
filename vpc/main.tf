# VPC Principal
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-igw"
    }
  )
}

# Subnets Públicas (para recursos que necesitan acceso a Internet)
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
      Type = "public"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Subnets Privadas para App Layer (Lambda, ECS, etc.)
resource "aws_subnet" "private_app" {
  count = length(var.private_app_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-private-app-subnet-${count.index + 1}"
      Type = "private-app"
      Layer = "application"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Subnets Privadas para Data Layer (RDS, ElastiCache, etc.)
resource "aws_subnet" "private_data" {
  count = length(var.private_data_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_data_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-private-data-subnet-${count.index + 1}"
      Type = "private-data"
      Layer = "data"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group para NAT Instance
resource "aws_security_group" "nat_instance" {
  count = var.enable_nat_instance ? 1 : 0

  name        = "${var.project_name}-${var.environment}-nat-instance-sg"
  description = "Security group for NAT Instance"
  vpc_id      = aws_vpc.main.id

  # Permitir tráfico saliente desde subnets privadas
  ingress {
    description = "All traffic from private subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = concat(var.private_app_subnet_cidrs, var.private_data_subnet_cidrs)
  }

  # Permitir todo el tráfico saliente a Internet
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-instance-sg"
    }
  )
}

# Elastic IP para NAT Instance
resource "aws_eip" "nat_instance" {
  count = var.enable_nat_instance ? 1 : 0

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-instance-eip"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Data source para obtener la AMI de NAT más reciente
data "aws_ami" "nat_instance" {
  count = var.enable_nat_instance ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# NAT Instance (t2.micro - gratis en Free Tier)
resource "aws_instance" "nat" {
  count = var.enable_nat_instance ? 1 : 0

  ami                         = data.aws_ami.nat_instance[0].id
  instance_type               = var.nat_instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.nat_instance[0].id]
  associate_public_ip_address = true
  source_dest_check           = false  # Requerido para NAT

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-instance"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Asociar Elastic IP a NAT Instance
resource "aws_eip_association" "nat_instance" {
  count = var.enable_nat_instance ? 1 : 0

  instance_id   = aws_instance.nat[0].id
  allocation_id = aws_eip.nat_instance[0].id
}

# Data source para obtener el network interface de la NAT Instance
data "aws_network_interface" "nat_instance" {
  count = var.enable_nat_instance ? 1 : 0

  filter {
    name   = "attachment.instance-id"
    values = [aws_instance.nat[0].id]
  }

  depends_on = [aws_instance.nat]
}

# Route Table para Subnets Públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-public-rt"
    }
  )
}

# Route Table para Subnets Privadas App Layer (con acceso a NAT Instance si está habilitado)
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  # Ruta a NAT Instance si está habilitado
  dynamic "route" {
    for_each = var.enable_nat_instance ? [1] : []
    content {
      cidr_block           = "0.0.0.0/0"
      network_interface_id = data.aws_network_interface.nat_instance[0].id
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-private-app-rt"
      Layer = "application"
    }
  )
}

# Route Table para Subnets Privadas Data Layer (sin acceso a Internet)
resource "aws_route_table" "private_data" {
  vpc_id = aws_vpc.main.id

  # Data layer no necesita ruta a Internet (más seguro)

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-private-data-rt"
      Layer = "data"
    }
  )
}

# Asociar Route Tables con Subnets Públicas
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Asociar Route Tables con Subnets Privadas App Layer
resource "aws_route_table_association" "private_app" {
  count = length(aws_subnet.private_app)

  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app.id
}

# Asociar Route Tables con Subnets Privadas Data Layer
resource "aws_route_table_association" "private_data" {
  count = length(aws_subnet.private_data)

  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.private_data.id
}

# Data source para obtener Availability Zones disponibles
data "aws_availability_zones" "available" {
  state = "available"
}
