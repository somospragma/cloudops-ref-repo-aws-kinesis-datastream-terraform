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

# -----------------------------------------------------------------------------
# Policy documents para Resource Policies (igual patrón que módulo KMS)
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "resource_policy" {
  provider = aws.project
  for_each = local.resource_policies

  dynamic "statement" {
    for_each = each.value.statements
    content {
      sid       = statement.value["sid"]
      effect    = statement.value["effect"]
      actions   = statement.value["actions"]
      resources = [aws_kinesis_stream.this[each.key].arn]

      principals {
        type        = statement.value["principals"]["type"]
        identifiers = statement.value["principals"]["identifiers"]
      }

      dynamic "condition" {
        for_each = statement.value["conditions"]
        content {
          test     = condition.value["test"]
          variable = condition.value["variable"]
          values   = condition.value["values"]
        }
      }
    }
  }
}
