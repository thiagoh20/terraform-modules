# Ejemplos de Commits para Semantic Release

Esta guía muestra ejemplos de commits que funcionan con la configuración de semantic-release.

## Formato de Commits

El formato básico es:
```
<type>(<scope>): <subject>

<body>

<footer>
```

## Ejemplos por Tipo

### 🚀 Features (Release Minor: 1.0.0 → 1.1.0)

```bash
# Nueva funcionalidad simple
git commit -m "feat: agregar soporte para CloudFront distributions"

# Con scope
git commit -m "feat(s3): agregar encriptación SSE-KMS para buckets"

# Con descripción detallada
git commit -m "feat(iam-oidc): agregar soporte para múltiples providers

Permite configurar múltiples proveedores OIDC en un solo módulo.
Incluye validación de configuración y documentación actualizada."
```

### 🐛 Bug Fixes (Release Patch: 1.0.0 → 1.0.1)

```bash
# Corrección simple
git commit -m "fix: corregir validación de variables en módulo S3"

# Con scope
git commit -m "fix(cloudfront): corregir error en configuración de cache"

# Con descripción
git commit -m "fix(iam-oidc): corregir permisos faltantes en policy

El módulo no estaba asignando correctamente los permisos necesarios
para las operaciones de lectura en el bucket S3."
```

### ⚡ Performance Improvements (Release Patch: 1.0.0 → 1.0.1)

```bash
git commit -m "perf: optimizar tiempo de inicialización de Terraform"

git commit -m "perf(s3): reducir número de llamadas a la API de AWS"
```

### ♻️ Code Refactoring (Release Patch: 1.0.0 → 1.0.1)

```bash
git commit -m "refactor: reorganizar estructura de módulos"

git commit -m "refactor(cloudfront): simplificar lógica de validación"
```

### 👷 Build System (Release Patch: 1.0.0 → 1.0.1)

```bash
git commit -m "build: actualizar versión de Terraform a 1.13.4"

git commit -m "build: agregar validación de formato en CI"
```

### 💥 BREAKING CHANGES (Release Major: 1.0.0 → 2.0.0)

```bash
# Breaking change simple
git commit -m "feat!: cambiar estructura de variables del módulo S3

BREAKING CHANGE: Las variables 'bucket_name' y 'bucket_region' han sido
reemplazadas por un objeto 'bucket_config'. Ver MIGRATION.md para más detalles."

# O usando el footer
git commit -m "refactor!: reorganizar estructura de outputs

BREAKING CHANGE: Los outputs ahora están agrupados por módulo.
Actualiza tus referencias de 'output_name' a 'module.output_name'."
```

### 📚 Documentation (NO genera release)

```bash
git commit -m "docs: actualizar README con ejemplos de uso"

git commit -m "docs(s3): agregar documentación de variables"
```

### 💅 Styles (NO genera release)

```bash
git commit -m "style: formatear código con terraform fmt"

git commit -m "style: corregir indentación en archivos .tf"
```

### ✅ Tests (NO genera release)

```bash
git commit -m "test: agregar tests para módulo CloudFront"

git commit -m "test: mejorar cobertura de tests de integración"
```

### 🔧 Continuous Integration (NO genera release)

```bash
git commit -m "ci: agregar step de validación de seguridad"

git commit -m "ci: actualizar workflow de release"
```

### Chore (NO genera release)

```bash
git commit -m "chore: actualizar dependencias"

git commit -m "chore: limpiar archivos temporales"
```

## Ejemplo de Changelog Generado

Cuando hagas commits como los de arriba, el `CHANGELOG.md` se verá así:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Breaking Changes Notice

⚠️ **IMPORTANT**: Breaking changes are marked with 💥 and require attention during upgrades.
Please read the migration guide for each breaking change before updating.

## [1.1.0] - 2024-02-17

### 🚀 Features
- agregar soporte para CloudFront distributions
- agregar encriptación SSE-KMS para buckets (s3)
- agregar soporte para múltiples providers (iam-oidc)

## [1.0.1] - 2024-02-16

### 🐛 Bug Fixes
- corregir validación de variables en módulo S3
- corregir error en configuración de cache (cloudfront)
- corregir permisos faltantes en policy (iam-oidc)

### ⚡ Performance Improvements
- optimizar tiempo de inicialización de Terraform
- reducir número de llamadas a la API de AWS (s3)

### ♻️ Code Refactoring
- reorganizar estructura de módulos
- simplificar lógica de validación (cloudfront)

### 👷 Build System
- actualizar versión de Terraform a 1.13.4
- agregar validación de formato en CI
```

## Ejemplo de Release Notes en GitHub

Las release notes en GitHub se verán organizadas con emojis:

```markdown
## 🚀 Features
- agregar soporte para CloudFront distributions
- agregar encriptación SSE-KMS para buckets (s3)

## 🐛 Bug Fixes
- corregir validación de variables en módulo S3
- corregir error en configuración de cache (cloudfront)

## ⚡ Performance Improvements
- optimizar tiempo de inicialización de Terraform
```

## Versiones y Tags

- **Major** (2.0.0): Solo con breaking changes
- **Minor** (1.1.0): Con features nuevas
- **Patch** (1.0.1): Con fixes, refactors, perf, build

Los tags se crearán como: `v1.0.0`, `v1.1.0`, `v2.0.0`, etc.

## Consejos

1. **Usa scopes** cuando sea relevante: `feat(s3): ...` es más claro que `feat: ...`
2. **Sé descriptivo** en el body cuando el cambio sea complejo
3. **Marca breaking changes** claramente con `!` o `BREAKING CHANGE:`
4. **No uses** `docs`, `style`, `test`, `ci`, `chore` si quieres generar un release
5. **Usa** `feat` para nuevas funcionalidades, `fix` para correcciones
