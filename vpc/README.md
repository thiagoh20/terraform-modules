# Módulo VPC para Terraform

Este módulo crea una VPC completa con arquitectura de 3 capas: subnets públicas (DMZ), subnets privadas de aplicación y subnets privadas de datos.

## Características

- ✅ VPC con DNS habilitado
- ✅ Arquitectura de 3 capas:
  - **Public Subnets (DMZ)**: Para NAT Instance
  - **Private App Subnets**: Para Lambda, ECS, etc.
  - **Private Data Subnets**: Para RDS, ElastiCache, etc.
- ✅ Internet Gateway
- ✅ NAT Instance (t2.micro - gratis en Free Tier)
- ✅ Route Tables configuradas automáticamente por capa
- ✅ Distribución automática en múltiples Availability Zones

## Uso

```hcl
module "vpc" {
  source = "git::https://github.com/thiagoh20/terraform-modules.git//vpc?ref=main"

  project_name = "myproject"
  environment  = "dev"

  vpc_cidr                = "10.0.0.0/16"
  public_subnet_cidrs     = ["10.0.1.0/24", "10.0.2.0/24"]        # DMZ
  private_app_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]     # App Layer
  private_data_subnet_cidrs = ["10.0.100.0/24", "10.0.200.0/24"]  # Data Layer
  enable_nat_instance     = true   # NAT Instance (t2.micro - gratis)
  nat_instance_type       = "t2.micro"

  tags = {
    Project     = "myproject"
    Environment = "dev"
  }
}
```

## Variables

| Variable | Descripción | Tipo | Default |
|----------|-------------|------|---------|
| `project_name` | Nombre del proyecto | `string` | - |
| `environment` | Ambiente (dev, staging, prod) | `string` | - |
| `vpc_cidr` | CIDR block para la VPC | `string` | `"10.0.0.0/16"` |
| `public_subnet_cidrs` | Lista de CIDR para subnets públicas (DMZ) | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `private_app_subnet_cidrs` | Lista de CIDR para subnets privadas de app (Lambda, ECS) | `list(string)` | `["10.0.10.0/24", "10.0.20.0/24"]` |
| `private_data_subnet_cidrs` | Lista de CIDR para subnets privadas de datos (RDS) | `list(string)` | `["10.0.100.0/24", "10.0.200.0/24"]` |
| `enable_nat_instance` | Habilitar NAT Instance | `bool` | `true` |
| `nat_instance_type` | Tipo de instancia para NAT (t2.micro para Free Tier) | `string` | `"t2.micro"` |
| `tags` | Tags adicionales | `map(string)` | `{}` |

## Outputs

| Output | Descripción |
|--------|-------------|
| `vpc_id` | ID de la VPC creada |
| `vpc_cidr_block` | CIDR block de la VPC |
| `public_subnet_ids` | Lista de IDs de subnets públicas (DMZ) |
| `private_app_subnet_ids` | Lista de IDs de subnets privadas de aplicación |
| `private_data_subnet_ids` | Lista de IDs de subnets privadas de datos |
| `internet_gateway_id` | ID del Internet Gateway |
| `nat_instance_id` | ID de la NAT Instance (si está habilitada) |
| `nat_instance_public_ip` | IP pública (Elastic IP) de la NAT Instance |

## ⚠️ Consideraciones de Costos

### AWS Free Tier
- ✅ VPC, Subnets, Internet Gateway: **GRATIS**
- ✅ Route Tables: **GRATIS**
- ✅ NAT Instance (t2.micro): **GRATIS** (750 horas/mes por 12 meses)
- ❌ NAT Gateway: **NO está en Free Tier** (~$32/mes + tráfico)

### Recomendación
- **Desarrollo/Free Tier**: `enable_nat_instance = true` con `nat_instance_type = "t2.micro"` (gratis)
- **Producción**: Considerar NAT Gateway para mayor disponibilidad (pero tiene costos)

## Arquitectura de 3 Capas

```
VPC (10.0.0.0/16)
│
├── 🌐 Public Layer (DMZ)
│   ├── Public Subnets (10.0.1.0/24, 10.0.2.0/24)
│   ├── Internet Gateway
│   ├── NAT Instance (t2.micro)
│   └── Route: 0.0.0.0/0 → IGW
│
├── 🔧 Private App Layer
│   ├── Private App Subnets (10.0.10.0/24, 10.0.20.0/24)
│   ├── Route: 0.0.0.0/0 → NAT Instance
│   └── Lambda, ECS (acceso a Internet vía NAT)
│
└── 💾 Private Data Layer
    ├── Private Data Subnets (10.0.100.0/24, 10.0.200.0/24)
    ├── Route: Sin acceso a Internet (más seguro)
    └── RDS, ElastiCache (sin acceso a Internet)
```

## Ejemplo Completo

```hcl
module "vpc" {
  source = "git::https://github.com/thiagoh20/terraform-modules.git//vpc?ref=main"

  project_name = "foodoffice"
  environment  = "dev"

  # Configuración para Free Tier
  enable_nat_gateway = false

  tags = {
    Project     = "FoodOffice"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Usar las subnets privadas de datos para RDS
module "rds" {
  source = "../rds"
  
  # ...
  subnet_ids = module.vpc.private_data_subnet_ids
}

# Lambda usa las subnets privadas de aplicación
# (configurar en SAM template o Lambda function)
# subnet_ids = module.vpc.private_app_subnet_ids
```
