# =============================================================================
# Invocación del Módulo Kinesis Data Streams (PC-IAC-026)
# =============================================================================
# NOTA: Este archivo SOLO contiene la invocación del módulo.
# Las transformaciones de configuración están en locals.tf (PC-IAC-026).
# =============================================================================

module "kinesis_streams" {
  source = "../"

  providers = {
    aws.project = aws.principal
  }

  # ---------------------------------------------------------------------------
  # Variables de gobernanza (PC-IAC-003)
  # ---------------------------------------------------------------------------
  client      = var.client
  project     = var.project
  environment = var.environment

  # ---------------------------------------------------------------------------
  # Configuración transformada de streams (PC-IAC-026)
  # ---------------------------------------------------------------------------
  # IMPORTANTE: Usar local.streams_config_transformed, NUNCA var.streams_config
  # La transformación en locals.tf:
  # - Construye la nomenclatura (PC-IAC-025)
  # - Inyecta el KMS ARN desde data.tf (PC-IAC-020)
  # ---------------------------------------------------------------------------
  streams_config = local.streams_config_transformed
}
