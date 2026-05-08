# Kinesis Data Streams Module

Módulo de Terraform para crear y gestionar **Amazon Kinesis Data Streams** siguiendo las mejores prácticas de seguridad y gobernanza de Pragma CloudOps.

## Descripción

Este módulo permite crear múltiples Kinesis Data Streams con:
- Soporte para modos **On-Demand** y **Provisioned**
- **Cifrado en reposo obligatorio** con KMS (PC-IAC-020)
- Configuración de período de retención (24-8760 horas)
- Métricas a nivel de shard para CloudWatch
- Nomenclatura y tagging estandarizados

## Uso

```hcl
module "kinesis_streams" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-kinesis-stream-terraform.git?ref=v1.0.0"

  providers = {
    aws.project = aws.principal
  }

  # Variables de gobernanza
  client      = var.client
  project     = var.project
  environment = var.environment

  # Configuración de streams (transformada en locals.tf del Root)
  streams_config = local.streams_config_transformed
}
```

## Ejemplo Completo

Ver el directorio `sample/` para un ejemplo funcional completo.

```hcl
# En el Root: locals.tf
locals {
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  streams_config_transformed = {
    for key, config in var.streams_config : key => merge(config, {
      name        = "${local.governance_prefix}-kinesis-${key}"
      kms_key_arn = length(config.kms_key_arn) > 0 ? config.kms_key_arn : data.aws_kms_key.kinesis.arn
    })
  }
}

# En el Root: main.tf
module "kinesis_streams" {
  source = "../"

  providers = {
    aws.project = aws.principal
  }

  client      = var.client
  project     = var.project
  environment = var.environment

  streams_config = local.streams_config_transformed
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws.project | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| client | Nombre del cliente o unidad de negocio (máx 10 caracteres) | `string` | n/a | yes |
| project | Nombre del proyecto (máx 15 caracteres) | `string` | n/a | yes |
| environment | Entorno de despliegue (dev, qa, stg, pdn, prod) | `string` | n/a | yes |
| streams_config | Mapa de configuración para los Kinesis Data Streams | `map(object)` | `{}` | no |

### Estructura de `streams_config`

```hcl
streams_config = {
  "stream-key" = {
    name                       = string       # Nombre completo del stream (construido por Root)
    stream_mode                = string       # "ON_DEMAND" o "PROVISIONED" (default: "ON_DEMAND")
    shard_count                = number       # Número de shards (requerido si PROVISIONED)
    retention_period           = number       # Horas de retención: 24-8760 (default: 24)
    kms_key_arn                = string       # ARN de KMS key (OBLIGATORIO)
    enforce_consumer_deletion  = bool         # Forzar eliminación de consumidores (default: false)
    shard_level_metrics        = list(string) # Métricas de shard (default: [])
    additional_tags            = map(string)  # Tags adicionales (default: {})
  }
}
```

### Métricas de Shard Disponibles

- `IncomingBytes`
- `IncomingRecords`
- `OutgoingBytes`
- `OutgoingRecords`
- `WriteProvisionedThroughputExceeded`
- `ReadProvisionedThroughputExceeded`
- `IteratorAgeMilliseconds`

## Outputs

| Name | Description |
|------|-------------|
| stream_arns | Mapa de ARNs de los streams, indexado por clave |
| stream_arns_list | Lista de ARNs de todos los streams |
| stream_names | Mapa de nombres de los streams, indexado por clave |
| stream_names_list | Lista de nombres de todos los streams |
| stream_ids | Mapa de IDs de los streams, indexado por clave |
| stream_shard_counts | Mapa de conteo de shards por stream |
| stream_retention_periods | Mapa de períodos de retención por stream |
| streams_summary | Resumen completo de todos los streams |

## Cumplimiento de Reglas PC-IAC

| Regla | Descripción | Implementación |
|-------|-------------|----------------|
| PC-IAC-001 | Estructura de Módulo | ✅ 10 archivos raíz + 8 archivos sample/ |
| PC-IAC-002 | Variables | ✅ Tipificación explícita, validaciones, `map(object)` |
| PC-IAC-003 | Nomenclatura | ✅ Nombre construido en Root, consumido vía `config.name` |
| PC-IAC-004 | Tagging | ✅ Tags base + `additional_tags` con `merge()` |
| PC-IAC-005 | Providers | ✅ Alias `aws.project` obligatorio |
| PC-IAC-006 | Versiones | ✅ `required_version >= 1.0.0`, provider pinning |
| PC-IAC-007 | Outputs | ✅ Outputs granulares (ARNs, IDs, Names) |
| PC-IAC-010 | For_Each | ✅ `for_each` para múltiples streams |
| PC-IAC-020 | Seguridad | ✅ Cifrado KMS obligatorio, validación de `kms_key_arn` |
| PC-IAC-023 | Responsabilidad Única | ✅ Solo crea recursos de Kinesis, no IAM/SG/VPC |

## Decisiones de Diseño

### 1. Cifrado Obligatorio (PC-IAC-020)

El módulo **requiere** un `kms_key_arn` para cada stream. No se permite crear streams sin cifrado:

```hcl
validation {
  condition = alltrue([
    for key, config in var.streams_config :
    length(config.kms_key_arn) > 0
  ])
  error_message = "El 'kms_key_arn' es obligatorio para cifrado en reposo (PC-IAC-020)."
}
```

**Justificación:** AWS Well-Architected Framework recomienda cifrado en reposo para todos los datos sensibles.

### 2. Nomenclatura en el Root (PC-IAC-025)

El nombre del stream (`config.name`) debe venir **ya construido** desde el Root:

```hcl
# Root construye el nombre
name = "${local.governance_prefix}-kinesis-${key}"
```

**Justificación:** El módulo no debe construir nomenclatura; solo consume configuración completa.

### 3. Modos de Capacidad

- **ON_DEMAND**: AWS gestiona automáticamente los shards. Ideal para cargas variables.
- **PROVISIONED**: El usuario especifica `shard_count`. Ideal para cargas predecibles.

```hcl
validation {
  condition = alltrue([
    for key, config in var.streams_config :
    config.stream_mode == "ON_DEMAND" || (config.stream_mode == "PROVISIONED" && config.shard_count != null && config.shard_count > 0)
  ])
  error_message = "Cuando stream_mode es 'PROVISIONED', shard_count debe ser mayor a 0."
}
```

### 4. Período de Retención

- **Mínimo**: 24 horas (default de AWS)
- **Máximo**: 8760 horas (365 días)
- **Costo**: Retención > 24 horas tiene costo adicional

### 5. Responsabilidad Única (PC-IAC-023)

Este módulo **NO** crea:
- ❌ IAM Roles/Policies (deben pasarse como variables)
- ❌ KMS Keys (deben pasarse como `kms_key_arn`)
- ❌ CloudWatch Alarms (módulo separado)
- ❌ Lambda Consumers (módulo separado)

## Recursos Creados

- `aws_kinesis_stream.this` - Kinesis Data Streams

## Consideraciones de Seguridad

1. **Cifrado**: Todos los streams usan cifrado KMS obligatorio
2. **Acceso**: Configurar IAM policies restrictivas para productores/consumidores
3. **Retención**: Considerar requisitos de compliance para el período de retención
4. **Monitoreo**: Habilitar `shard_level_metrics` para visibilidad operacional

## Referencias

- [Amazon Kinesis Data Streams Documentation](https://docs.aws.amazon.com/streams/latest/dev/)
- [Terraform AWS Provider - kinesis_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_stream)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
