# =============================================================================
# Valores locales y transformaciones (PC-IAC-012)
# =============================================================================

locals {
  # ---------------------------------------------------------------------------
  # Prefijo de gobernanza (PC-IAC-003)
  # ---------------------------------------------------------------------------
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # ---------------------------------------------------------------------------
  # Tags base del módulo (PC-IAC-004)
  # ---------------------------------------------------------------------------
  base_module_tags = {
    "managed-by" = "terraform"
    "module"     = "kinesis-stream"
  }

  # ---------------------------------------------------------------------------
  # Configuración procesada de streams (PC-IAC-009, PC-IAC-012)
  # ---------------------------------------------------------------------------
  # NOTA: El nombre ya viene construido desde el Root (PC-IAC-025)
  # Este módulo solo consume la configuración, no construye nomenclatura
  streams_processed = {
    for key, config in var.streams_config : key => {
      name                      = config.name
      stream_mode               = config.stream_mode
      shard_count               = config.stream_mode == "PROVISIONED" ? config.shard_count : null
      retention_period          = config.retention_period
      kms_key_arn               = config.kms_key_arn
      enforce_consumer_deletion = config.enforce_consumer_deletion
      shard_level_metrics       = config.shard_level_metrics

      # Merge de tags: Name + tags base del módulo + tags adicionales (PC-IAC-004)
      tags = merge(
        { Name = config.name },
        local.base_module_tags,
        config.additional_tags
      )
    }
  }
}
