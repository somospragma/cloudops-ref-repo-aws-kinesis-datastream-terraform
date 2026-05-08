# =============================================================================
# Transformaciones del Root/Sample (PC-IAC-012, PC-IAC-025, PC-IAC-026)
# =============================================================================

locals {
  # ---------------------------------------------------------------------------
  # Prefijo de gobernanza para nomenclatura (PC-IAC-003, PC-IAC-025)
  # ---------------------------------------------------------------------------
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # ---------------------------------------------------------------------------
  # Tags de gobernanza base (PC-IAC-004)
  # ---------------------------------------------------------------------------
  governance_tags = {
    "client"      = var.client
    "project"     = var.project
    "environment" = var.environment
    "managed-by"  = "terraform"
  }

  # ---------------------------------------------------------------------------
  # Transformación de configuración de streams (PC-IAC-026)
  # ---------------------------------------------------------------------------
  # Patrón: terraform.tfvars → variables.tf → data.tf → locals.tf → main.tf
  #
  # Esta transformación:
  # 1. Construye el nombre completo con nomenclatura (PC-IAC-003, PC-IAC-025)
  # 2. Inyecta el KMS ARN desde data.tf si está vacío (PC-IAC-020)
  # 3. Prepara la configuración para consumo del módulo
  # ---------------------------------------------------------------------------
  streams_config_transformed = {
    for key, config in var.streams_config : key => {
      # Nombre construido con nomenclatura de gobernanza (PC-IAC-003, PC-IAC-025)
      name = "${local.governance_prefix}-kinesis-${key}"

      # Configuración de capacidad
      stream_mode = config.stream_mode
      shard_count = config.shard_count

      # Período de retención
      retention_period = config.retention_period

      # KMS ARN: inyección dinámica si está vacío (PC-IAC-020, PC-IAC-026)
      kms_key_arn = length(config.kms_key_arn) > 0 ? config.kms_key_arn : data.aws_kms_key.kinesis.arn

      # Configuración adicional
      enforce_consumer_deletion = config.enforce_consumer_deletion
      shard_level_metrics       = config.shard_level_metrics

      # Tags: merge de gobernanza + adicionales (PC-IAC-004)
      additional_tags = merge(
        local.governance_tags,
        config.additional_tags
      )
    }
  }
}
