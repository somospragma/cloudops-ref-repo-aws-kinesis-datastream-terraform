# =============================================================================
# Data Sources del Módulo (PC-IAC-011)
# =============================================================================
#
# NOTA: Los Data Sources deben declararse en el Módulo Raíz (IaC Root),
# NO en los Módulos de Referencia.
#
# Este módulo recibe todos los IDs y ARNs necesarios a través de variables
# de entrada (var.*), siguiendo el principio de Responsabilidad Única (PC-IAC-023).
#
# Ejemplo de Data Sources que el Root debe declarar:
#
#   data "aws_kms_key" "kinesis" {
#     key_id = "alias/${var.client}-${var.project}-${var.environment}-kms-kinesis"
#   }
#
# =============================================================================

# Obtener información de la región actual (permitido en módulos)
data "aws_region" "current" {
  provider = aws.project
}

# Obtener información de la cuenta actual (permitido en módulos)
data "aws_caller_identity" "current" {
  provider = aws.project
}
