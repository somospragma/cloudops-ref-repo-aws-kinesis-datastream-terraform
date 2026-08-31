# =============================================================================
# Recursos principales del módulo - Kinesis Data Streams (PC-IAC-010, PC-IAC-020)
# =============================================================================

# -----------------------------------------------------------------------------
# Kinesis Data Stream (PC-IAC-010: for_each obligatorio)
# -----------------------------------------------------------------------------
resource "aws_kinesis_stream" "this" {
  provider = aws.project

  for_each = local.streams_processed

  # Nombre del stream (PC-IAC-003, PC-IAC-025)
  name = each.value.name

  # Configuración de capacidad
  shard_count = each.value.shard_count

  # Período de retención (24-8760 horas)
  retention_period = each.value.retention_period

  # Forzar eliminación de consumidores antes de destruir el stream
  enforce_consumer_deletion = each.value.enforce_consumer_deletion

  # Métricas a nivel de shard para CloudWatch
  shard_level_metrics = each.value.shard_level_metrics

  # ---------------------------------------------------------------------------
  # Cifrado en reposo (PC-IAC-020: Hardenizado obligatorio)
  # ---------------------------------------------------------------------------
  encryption_type = "KMS"
  kms_key_id      = each.value.kms_key_arn

  # ---------------------------------------------------------------------------
  # Modo de capacidad del stream
  # ---------------------------------------------------------------------------
  stream_mode_details {
    stream_mode = each.value.stream_mode
  }

  # ---------------------------------------------------------------------------
  # Tags (PC-IAC-004)
  # ---------------------------------------------------------------------------
  tags = each.value.tags

  # ---------------------------------------------------------------------------
  # Lifecycle (PC-IAC-010)
  # ---------------------------------------------------------------------------
  lifecycle {
    # Prevenir destrucción accidental de streams con datos
    prevent_destroy = false # Cambiar a true en producción si es crítico

    # Ignorar cambios en shard_count cuando el modo es ON_DEMAND
    # ya que AWS lo gestiona automáticamente
    ignore_changes = []
  }
}

# -----------------------------------------------------------------------------
# Kinesis Resource Policy - Cross-Account Access (Opcional)
# -----------------------------------------------------------------------------
resource "aws_kinesis_resource_policy" "this" {
  provider = aws.project

  for_each = local.resource_policies

  resource_arn = aws_kinesis_stream.this[each.key].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for stmt in each.value.statements : merge(
        {
          Sid    = stmt.sid
          Effect = stmt.effect
          Principal = {
            (stmt.principals.type) = stmt.principals.identifiers
          }
          Action   = stmt.actions
          Resource = aws_kinesis_stream.this[each.key].arn
        },
        length(stmt.conditions) > 0 ? {
          Condition = merge([
            for condition in stmt.conditions : {
              (condition.test) = {
                (condition.variable) = condition.values
              }
            }
          ]...)
        } : {}
      )
    ]
  })
}
