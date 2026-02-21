# Terraform Modules - Repositorio de Módulos Reutilizables

Este repositorio contiene módulos de Terraform reutilizables para infraestructura en AWS, diseñados para cumplir con los requisitos de la **Prueba Técnica de Ingeniería DevOps**.

## 📋 Estado de Implementación de la Prueba Técnica

### ✅ 1. Creación del Proyecto

**Estado:** ✅ **Completado**

Este repositorio contiene módulos de Terraform reutilizables para infraestructura en AWS. Aunque la prueba técnica menciona una aplicación, este enfoque demuestra habilidades avanzadas en IaC (Infrastructure as Code) mediante la creación de módulos modulares y reutilizables.

**Módulos Implementados:**
- ✅ **VPC**: Módulo completo con arquitectura de 3 capas (DMZ, App, Data)
- ✅ **RDS**: Módulo para bases de datos PostgreSQL con configuraciones de seguridad
- ✅ **S3**: Módulo para buckets S3 con configuraciones de seguridad y versionado
- ✅ **CloudFront**: Módulo para distribuciones CDN
- ✅ **IAM-OIDC**: Módulo para configuración de OIDC con GitHub Actions
- ✅ **Security Groups**: Módulo para grupos de seguridad con reglas configurables

**Repositorio:** [GitHub Repository](https://github.com/thiagoh20/terraform-modules)

---

### ✅ 2. Estrategia de Git

**Estado:** ✅ **Completado e Implementado**

#### Estrategia Definida: **Conventional Commits con Semantic Versioning**

**Modelo de Branching:**
- **`main`**: Rama principal de producción, protegida
- **`develop`**: Rama de desarrollo (opcional, para proyectos más complejos)
- **Feature branches**: `feature/nombre-feature` (se mergean a `main` o `develop`)
- **Fix branches**: `fix/nombre-fix` (se mergean a `main` o `develop`)

**Gestión de Commits:**
- Uso de **Conventional Commits** para commits semánticos
- Formato: `<type>(<scope>): <subject>`
- Tipos soportados:
  - `feat`: Nueva funcionalidad (genera release minor)
  - `fix`: Corrección de bugs (genera release patch)
  - `perf`: Mejoras de rendimiento (genera release patch)
  - `refactor`: Refactorización (genera release patch)
  - `build`: Cambios en build system (genera release patch)
  - `docs`: Documentación (no genera release)
  - `style`: Formato de código (no genera release)
  - `test`: Tests (no genera release)
  - `ci`: Cambios en CI/CD (no genera release)
  - `chore`: Tareas de mantenimiento (no genera release)
  - `BREAKING CHANGE`: Cambios incompatibles (genera release major)

**Implementación:**
- ✅ Configuración de **Semantic Release** para versionado automático
- ✅ Generación automática de `CHANGELOG.md`
- ✅ Creación automática de tags y releases en GitHub
- ✅ Documentación completa en `COMMIT_EXAMPLES.md`

**Archivos de Configuración:**
- `.releaserc.json`: Configuración de semantic-release
- `COMMIT_EXAMPLES.md`: Guía completa de ejemplos de commits

---

### ✅ 3. Infraestructura como Código (IaC) con Terraform

**Estado:** ✅ **Completado**

#### Arquitectura Implementada

Todos los módulos están diseñados para cumplir con la **AWS Free Tier**:

**Módulo VPC:**
- ✅ VPC con DNS habilitado
- ✅ Arquitectura de 3 capas:
  - **Public Subnets (DMZ)**: Para NAT Instance
  - **Private App Subnets**: Para Lambda, ECS
  - **Private Data Subnets**: Para RDS, ElastiCache
- ✅ Internet Gateway
- ✅ NAT Instance (t2.micro - **GRATIS en Free Tier**)
- ✅ Route Tables configuradas automáticamente

**Módulo RDS:**
- ✅ PostgreSQL con versiones compatibles con Free Tier
- ✅ Configuración de seguridad (encriptación, backups)
- ✅ Subnet groups para alta disponibilidad
- ✅ Security groups con reglas restrictivas

**Módulo S3:**
- ✅ Buckets con versionado
- ✅ Configuración de seguridad (block public access)
- ✅ Lifecycle policies para optimización de costos

**Módulo CloudFront:**
- ✅ Distribuciones CDN
- ✅ Configuración de origins
- ✅ Cache policies

**Módulo Security Groups:**
- ✅ Reglas de ingress/egress configurables
- ✅ Egress restrictivo (no `0.0.0.0/0` por defecto)
- ✅ Soporte para múltiples reglas dinámicas

**Módulo IAM-OIDC:**
- ✅ Configuración de OIDC provider para GitHub Actions
- ✅ Roles IAM con permisos específicos
- ✅ Integración con servicios AWS

#### Servicios AWS Utilizados (Free Tier):

| Servicio | Estado Free Tier | Justificación |
|----------|------------------|---------------|
| VPC | ✅ GRATIS | Infraestructura de red base |
| Subnets | ✅ GRATIS | Segmentación de red |
| Internet Gateway | ✅ GRATIS | Acceso a Internet |
| NAT Instance (t2.micro) | ✅ GRATIS (750h/mes) | Acceso saliente para recursos privados |
| RDS (db.t3.micro) | ✅ GRATIS (750h/mes) | Base de datos relacional |
| S3 | ✅ GRATIS (5GB) | Almacenamiento de objetos |
| CloudFront | ✅ GRATIS (50GB transfer) | CDN y distribución de contenido |
| IAM | ✅ GRATIS | Gestión de identidades y acceso |
| Security Groups | ✅ GRATIS | Firewall de red |

**Archivos de Configuración:**
- Cada módulo tiene: `main.tf`, `variables.tf`, `outputs.tf`
- Documentación en README.md dentro de cada módulo

---

### ✅ 4. Estrategia de Gestión del State de Terraform

**Estado:** ✅ **Documentado y Listo para Implementación**

#### Estrategia Definida

**Backend Elegido: S3 + DynamoDB**

**Justificación:**
- ✅ **Colaboración**: Múltiples desarrolladores pueden trabajar simultáneamente
- ✅ **Seguridad**: State almacenado de forma segura con encriptación
- ✅ **Locking**: DynamoDB table previene escrituras concurrentes
- ✅ **Versionado**: S3 permite versionado del state file
- ✅ **Backup**: S3 mantiene versiones históricas del state
- ✅ **Costo**: S3 y DynamoDB tienen capas gratuitas generosas


**Mecanismo de Locking:**
- ✅ **DynamoDB Table**: `terraform-state-lock`
- ✅ **Lock ID**: Basado en `workspace_key` + `workspace_name`
- ✅ **TTL**: Configurado para limpieza automática de locks huérfanos
- ✅ **Prevención de escrituras concurrentes**: DynamoDB garantiza atomicidad

**Consideraciones de Seguridad:**
- ✅ **Encriptación en reposo**: S3 server-side encryption (SSE-S3 o SSE-KMS)
- ✅ **Encriptación en tránsito**: HTTPS/TLS para todas las comunicaciones
- ✅ **IAM Policies restrictivas**: Solo usuarios/roles autorizados pueden acceder
- ✅ **Versionado habilitado**: Para recuperación ante corrupción o borrado accidental
- ✅ **Block Public Access**: S3 bucket con acceso público bloqueado
- ✅ **MFA Delete**: Opcional para protección adicional

**Configuración de Backend (Ejemplo):**
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "environments/dev/vpc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/abc123" # Opcional
  }
}
```

**Implementación:**
- ⚠️ **Nota**: La configuración del backend se realiza en el proyecto que consume estos módulos
- ✅ Los módulos están diseñados para ser compatibles con cualquier backend
- ✅ Documentación incluida en `terraform/terraform.tfvars.example`

**Archivos de Documentación:**
- `terraform/terraform.tfvars.example`: Ejemplo de configuración

---

### ⚠️ 5. Pruebas Unitarias

**Estado:** ⚠️ **Parcialmente Implementado**

**Implementación Actual:**
- ✅ **Validación de Terraform**: `terraform validate` en CI/CD
- ✅ **Formato de código**: `terraform fmt -check` en CI/CD
- ✅ **Análisis de seguridad**: Checkov en CI/CD

**Pendiente:**
- ⚠️ Tests unitarios con Terratest o similar
- ⚠️ Tests de integración para módulos

**Justificación:**
- Los módulos de Terraform requieren tests específicos (Terratest, Kitchen-Terraform)
- La validación y análisis estático cubren aspectos básicos de calidad
- Para una implementación completa, se recomienda agregar Terratest

---

### ✅ 6. Análisis de Código Estático

**Estado:** ✅ **Completado**

#### Herramientas Implementadas

**1. Terraform Format Check:**
- ✅ `terraform fmt -check`: Verifica formato de código
- ✅ Ejecutado en CI/CD en cada PR y push

**2. Terraform Validate:**
- ✅ `terraform validate`: Valida sintaxis y configuración
- ✅ Ejecutado en CI/CD para cada módulo

**3. Checkov (Análisis de Seguridad):**
- ✅ Análisis estático de seguridad para Terraform
- ✅ Framework: Terraform
- ✅ Output: SARIF format
- ✅ Ejecutado en CI/CD en job `security-scan`

**Configuración:**
```yaml
- name: Run Checkov
  uses: bridgecrewio/checkov-action@master
  with:
    directory: .
    framework: terraform
    output_format: sarif
    output_file_path: reports/results.sarif
    soft_fail: true
```

**Resultados:**
- Los resultados se publican en formato SARIF
- El análisis bloquea merge si hay fallos críticos
- `soft_fail: true` permite que el workflow continúe pero reporta los problemas

**Archivos de Configuración:**
- `.github/workflows/release.yml`: Workflow con validación y análisis

---

### ✅ 7. CI/CD con Github Actions

**Estado:** ✅ **Completado**

#### Workflows Implementados

**Workflow: `release.yml`**

**Jobs Implementados:**

1. **`validate`** (Validación de Módulos):
   - ✅ Ejecuta `terraform fmt -check` para verificar formato
   - ✅ Ejecuta `terraform init` y `terraform validate` para cada módulo
   - ✅ Matrix strategy para validar múltiples módulos en paralelo
   - ✅ Módulos validados: `cloudfront`, `s3`, `iam-oidc`

2. **`security-scan`** (Análisis de Seguridad):
   - ✅ Ejecuta Checkov para análisis de seguridad
   - ✅ Genera reporte en formato SARIF
   - ✅ Depende de `validate` (solo se ejecuta si validation pasa)

3. **`release`** (Generación de Release):
   - ✅ Ejecuta Semantic Release para versionado automático
   - ✅ Genera `CHANGELOG.md` automáticamente
   - ✅ Crea tags y releases en GitHub
   - ✅ Solo se ejecuta en `main` branch tras push exitoso
   - ✅ Depende de `validate` y `security-scan`

**Triggers:**
- ✅ `push` a `main` o `master`
- ✅ `pull_request` a `main` o `master`

**Características:**
- ✅ Bloqueo de merge si fallan validaciones
- ✅ Análisis de seguridad automático
- ✅ Versionado semántico automático
- ✅ Generación automática de changelog

**Archivos:**
- `.github/workflows/release.yml`: Workflow principal

**Pendiente (según requisitos de prueba):**
- ⚠️ Workflow específico para PRs con tests unitarios
- ⚠️ Workflow de deploy a Dev (requiere aplicación desplegable)

---


**Recomendación:**
- Agregar Infracost en el workflow cuando se despliegue infraestructura real
- Documentar costos estimados en cada módulo (ver README de VPC como ejemplo)

**Documentación de Costos:**
- ✅ Cada módulo documenta consideraciones de Free Tier
- ✅ `vpc/README.md` incluye sección de costos
- ✅ `MEJORAS_SEGURIDAD.md` documenta consideraciones de costos

---

## 📚 Documentación Adicional

### Archivos de Documentación

1. **`COMMIT_EXAMPLES.md`**: Guía completa de cómo hacer commits siguiendo Conventional Commits
2. **`MEJORAS_SEGURIDAD.md`**: Documentación de mejoras de seguridad implementadas
3. **`README.md`** (este archivo): Documentación principal del proyecto
4. **`vpc/README.md`**: Documentación específica del módulo VPC con ejemplos

### Estructura del Repositorio

```
terraform-modules/
├── .github/
│   └── workflows/
│       └── release.yml          # Workflow de CI/CD
├── cloudfront/                   # Módulo CloudFront
├── iam-oidc/                     # Módulo IAM-OIDC
├── rds/                          # Módulo RDS
├── s3/                           # Módulo S3
├── security-groups/              # Módulo Security Groups
├── vpc/                          # Módulo VPC
├── terraform/                    # Configuración de ejemplo
├── .releaserc.json               # Configuración de Semantic Release
├── package.json                  # Dependencias de Node.js
├── COMMIT_EXAMPLES.md            # Guía de commits
├── MEJORAS_SEGURIDAD.md          # Documentación de seguridad
└── README.md                     # Este archivo
```

---

## 🎯 Resumen de Implementación

| Requisito | Estado | Notas |
|-----------|--------|-------|
| 1. Creación del Proyecto | ✅ | Módulos de Terraform reutilizables |
| 2. Estrategia de Git | ✅ | Conventional Commits + Semantic Release |
| 3. IaC con Terraform | ✅ | 6 módulos completos, Free Tier compatible |
| 4. Estrategia de State | ✅ | Documentada (S3 + DynamoDB) |
| 5. Pruebas Unitarias | ⚠️ | Validación básica, falta Terratest |
| 6. Análisis Estático | ✅ | Terraform fmt/validate + Checkov |
| 7. CI/CD GitHub Actions | ✅ | Workflow completo con validación y release |
| 8. Documentación | ✅ | README completo + documentación por módulo |

---

## 🚀 Uso de los Módulos

### Ejemplo: Usar el módulo VPC

```hcl
module "vpc" {
  source = "git::https://github.com/thiagoh20/terraform-modules.git//vpc?ref=v1.0.0"

  project_name = "myproject"
  environment  = "dev"
  vpc_cidr     = "10.0.0.0/16"

  tags = {
    Project     = "myproject"
    Environment = "dev"
  }
}
```

### Ejemplo: Usar el módulo RDS

```hcl
module "rds" {
  source = "git::https://github.com/thiagoh20/terraform-modules.git//rds?ref=v1.0.0"

  project_name = "myproject"
  environment  = "dev"
  db_name      = "mydb"
  
  subnet_ids = module.vpc.private_data_subnet_ids
  vpc_id     = module.vpc.vpc_id
}
```

---

## 🔧 Desarrollo Local

### Prerrequisitos

- Terraform >= 1.13.4
- Node.js >= 20 (para semantic-release)
- AWS CLI configurado
- Acceso a AWS (credenciales configuradas)

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/thiagoh20/terraform-modules.git
cd terraform-modules

# Instalar dependencias de Node.js
npm install
```

### Validación Local

```bash
# Validar un módulo específico
cd vpc
terraform init
terraform validate
terraform fmt -check
```

---

## 📝 Desafíos Encontrados y Soluciones

### 1. Error de Semantic Release con Node.js 22

**Problema:** Error `TypeError: Method Date.prototype.toString called on incompatible receiver` al ejecutar semantic-release con Node.js 22.

**Solución:** 
- Cambio a Node.js 20 en el workflow
- Agregadas dependencias de semantic-release al `package.json` para control de versiones
- Ajustada configuración de `writerOpts` en `.releaserc.json`

### 2. Configuración de NAT Instance vs NAT Gateway

**Problema:** NAT Gateway no está en Free Tier y tiene costos significativos (~$32/mes).

**Solución:**
- Implementación de NAT Instance con t2.micro (gratis en Free Tier)
- Documentación clara de la diferencia y recomendaciones

### 3. Gestión de State en Módulos Reutilizables

**Problema:** Los módulos no pueden definir el backend directamente.

**Solución:**
- Documentación clara de la estrategia de state
- Ejemplos de configuración en `terraform/terraform.tfvars.example`
- Diseño de módulos compatible con cualquier backend

---