# =============================================================================
# Data Sources del Root/Sample (PC-IAC-020, PC-IAC-026)
# =============================================================================

# -----------------------------------------------------------------------------
# KMS Key para cifrado de Kinesis Streams (PC-IAC-020)
# -----------------------------------------------------------------------------
# Obtiene el ARN de la KMS key usando el alias definido en variables.
# Este ARN se inyecta en la configuración de streams en locals.tf
# siguiendo el patrón de transformación PC-IAC-026.
# -----------------------------------------------------------------------------
data "aws_kms_key" "kinesis" {
  provider = aws.principal

  key_id = var.kms_key_alias
}

# -----------------------------------------------------------------------------
# Información de la cuenta AWS actual
# -----------------------------------------------------------------------------
data "aws_caller_identity" "current" {
  provider = aws.principal
}

# -----------------------------------------------------------------------------
# Información de la región AWS actual
# -----------------------------------------------------------------------------
data "aws_region" "current" {
  provider = aws.principal
}
