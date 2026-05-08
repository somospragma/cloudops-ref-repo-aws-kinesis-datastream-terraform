# Kinesis Data Streams Module - Sample

Ejemplo funcional del módulo de Kinesis Data Streams siguiendo el patrón de transformación PC-IAC-026.

## Flujo de Datos (PC-IAC-026)

```
terraform.tfvars → variables.tf → data.tf → locals.tf → main.tf → module
```

1. **terraform.tfvars**: Define valores con `kms_key_arn = ""` (vacío para inyección dinámica)
2. **variables.tf**: Declara variables de gobernanza y `streams_config`
3. **data.tf**: Obtiene el ARN de la KMS key por alias
4. **locals.tf**: Transforma la configuración, inyecta KMS ARN y construye nomenclatura
5. **main.tf**: Invoca el módulo con `local.streams_config_transformed`

## Estructura de Archivos

```
sample/
├── README.md           # Este archivo
├── data.tf             # Data sources (KMS key lookup)
├── locals.tf           # Transformaciones y nomenclatura
├── main.tf             # Invocación del módulo
├── outputs.tf          # Outputs del ejemplo
├── providers.tf        # Configuración del provider AWS
├── terraform.tfvars    # Valores de ejemplo
└── variables.tf        # Variables de entrada
```

## Uso

### 1. Configurar credenciales AWS

```bash
export AWS_PROFILE=your-profile
# o
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx
export AWS_REGION=us-east-1
```

### 2. Personalizar variables

Editar `terraform.tfvars` con los valores de tu proyecto:

```hcl
client      = "pragma"
project     = "dataplatform"
environment = "dev"

kms_key_alias = "alias/kinesis-key"  # Alias de tu KMS key existente

streams_config = {
  "events" = {
    stream_mode      = "ON_DEMAND"
    retention_period = 48
    kms_key_arn      = ""  # Se inyecta dinámicamente desde data.tf
    shard_level_metrics = ["IncomingBytes", "OutgoingBytes"]
    additional_tags = {
      "data-classification" = "confidential"
    }
  }
}
```

### 3. Ejecutar Terraform

```bash
terraform init
terraform plan
terraform apply
```

## Ejemplo de Configuración

### Stream On-Demand (Recomendado)

```hcl
streams_config = {
  "user-events" = {
    stream_mode      = "ON_DEMAND"
    retention_period = 24
    kms_key_arn      = ""
  }
}
```

### Stream Provisioned

```hcl
streams_config = {
  "high-throughput" = {
    stream_mode      = "PROVISIONED"
    shard_count      = 4
    retention_period = 168  # 7 días
    kms_key_arn      = ""
    shard_level_metrics = [
      "IncomingBytes",
      "IncomingRecords",
      "OutgoingBytes",
      "OutgoingRecords"
    ]
  }
}
```

### Múltiples Streams

```hcl
streams_config = {
  "orders" = {
    stream_mode      = "ON_DEMAND"
    retention_period = 72
    kms_key_arn      = ""
    additional_tags = {
      "domain" = "commerce"
    }
  }
  "notifications" = {
    stream_mode      = "ON_DEMAND"
    retention_period = 24
    kms_key_arn      = ""
    additional_tags = {
      "domain" = "messaging"
    }
  }
  "analytics" = {
    stream_mode      = "PROVISIONED"
    shard_count      = 2
    retention_period = 168
    kms_key_arn      = ""
    additional_tags = {
      "domain" = "analytics"
    }
  }
}
```

## Prerequisitos

1. **KMS Key**: Debe existir una KMS key con el alias especificado en `kms_key_alias`
2. **Permisos IAM**: El rol de ejecución debe tener permisos para:
   - `kinesis:*` en los streams
   - `kms:Encrypt`, `kms:Decrypt`, `kms:GenerateDataKey` en la KMS key

## Outputs

| Output | Descripción |
|--------|-------------|
| stream_arns | Mapa de ARNs de los streams |
| stream_names | Mapa de nombres de los streams |
| streams_summary | Resumen completo de todos los streams |

## Limpieza

```bash
terraform destroy
```

## Notas

- El `kms_key_arn` vacío en `terraform.tfvars` es intencional (PC-IAC-026)
- La inyección del ARN real ocurre en `locals.tf` usando `data.aws_kms_key`
- La nomenclatura sigue el patrón: `{client}-{project}-{environment}-kinesis-{key}`
