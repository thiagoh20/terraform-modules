# Módulo VPC para Terraform

Este módulo crea una VPC completa con subnets públicas y privadas, Internet Gateway y opcionalmente NAT Gateway.

## Características

- ✅ VPC con DNS habilitado
- ✅ Subnets públicas (para recursos con acceso a Internet)
- ✅ Subnets privadas (para RDS y recursos sin acceso directo a Internet)
- ✅ Internet Gateway
- ✅ NAT Gateway opcional (deshabilitado por defecto para Free Tier)
- ✅ Route Tables configuradas automáticamente
- ✅ Distribución automática en múltiples Availability Zones

## Uso

```hcl
module "vpc" {
  source = "git::https://github.com/thiagoh20/terraform-modules.git//vpc?ref=main"

  project_name = "myproject"
  environment  = "dev"

  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  enable_nat_gateway  = false  # true para producción

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
| `public_subnet_cidrs` | Lista de CIDR para subnets públicas | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `private_subnet_cidrs` | Lista de CIDR para subnets privadas | `list(string)` | `["10.0.10.0/24", "10.0.20.0/24"]` |
| `enable_nat_gateway` | Habilitar NAT Gateway | `bool` | `false` |
| `tags` | Tags adicionales | `map(string)` | `{}` |

## Outputs

| Output | Descripción |
|--------|-------------|
| `vpc_id` | ID de la VPC creada |
| `vpc_cidr_block` | CIDR block de la VPC |
| `public_subnet_ids` | Lista de IDs de subnets públicas |
| `private_subnet_ids` | Lista de IDs de subnets privadas |
| `internet_gateway_id` | ID del Internet Gateway |
| `nat_gateway_id` | ID del NAT Gateway (si está habilitado) |

## ⚠️ Consideraciones de Costos

### AWS Free Tier
- ✅ VPC, Subnets, Internet Gateway: **GRATIS**
- ✅ Route Tables: **GRATIS**
- ❌ NAT Gateway: **NO está en Free Tier** (~$32/mes + tráfico)

### Recomendación
- **Desarrollo**: `enable_nat_gateway = false` (usar solo subnets públicas si es necesario)
- **Producción**: `enable_nat_gateway = true` (para recursos privados que necesiten salida a Internet)

## Arquitectura

```
VPC (10.0.0.0/16)
├── Public Subnets (10.0.1.0/24, 10.0.2.0/24)
│   └── Internet Gateway
│   └── Route: 0.0.0.0/0 → IGW
│
└── Private Subnets (10.0.10.0/24, 10.0.20.0/24)
    └── NAT Gateway (opcional)
    └── Route: 0.0.0.0/0 → NAT Gateway
    └── RDS, Lambda (sin IP pública)
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

# Usar las subnets privadas para RDS
module "rds" {
  source = "../rds"
  
  # ...
  subnet_ids = module.vpc.private_subnet_ids
}
```
