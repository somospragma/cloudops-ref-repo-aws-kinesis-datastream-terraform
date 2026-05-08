# =============================================================================
# Outputs del módulo (PC-IAC-007, PC-IAC-014)
# =============================================================================

# -----------------------------------------------------------------------------
# Outputs granulares - ARNs (PC-IAC-007)
# -----------------------------------------------------------------------------

output "stream_arns" {
  description = "Mapa de ARNs de los Kinesis Data Streams creados, indexado por la clave del stream."
  value = {
    for key, stream in aws_kinesis_stream.this : key => stream.arn
  }
}

output "stream_arns_list" {
  description = "Lista de ARNs de todos los Kinesis Data Streams creados."
  value       = values(aws_kinesis_stream.this)[*].arn
}

# -----------------------------------------------------------------------------
# Outputs granulares - Names (PC-IAC-007)
# -----------------------------------------------------------------------------

output "stream_names" {
  description = "Mapa de nombres de los Kinesis Data Streams creados, indexado por la clave del stream."
  value = {
    for key, stream in aws_kinesis_stream.this : key => stream.name
  }
}

output "stream_names_list" {
  description = "Lista de nombres de todos los Kinesis Data Streams creados."
  value       = values(aws_kinesis_stream.this)[*].name
}

# -----------------------------------------------------------------------------
# Outputs granulares - IDs (PC-IAC-007)
# -----------------------------------------------------------------------------

output "stream_ids" {
  description = "Mapa de IDs de los Kinesis Data Streams creados, indexado por la clave del stream."
  value = {
    for key, stream in aws_kinesis_stream.this : key => stream.id
  }
}

# -----------------------------------------------------------------------------
# Outputs de configuración
# -----------------------------------------------------------------------------

output "stream_shard_counts" {
  description = "Mapa de conteo de shards por stream (solo para modo PROVISIONED)."
  value = {
    for key, stream in aws_kinesis_stream.this : key => stream.shard_count
  }
}

output "stream_retention_periods" {
  description = "Mapa de períodos de retención (en horas) por stream."
  value = {
    for key, stream in aws_kinesis_stream.this : key => stream.retention_period
  }
}

# -----------------------------------------------------------------------------
# Output completo para debugging (usar con precaución)
# -----------------------------------------------------------------------------

output "streams_summary" {
  description = "Resumen de todos los streams creados con información clave."
  value = {
    for key, stream in aws_kinesis_stream.this : key => {
      arn              = stream.arn
      name             = stream.name
      shard_count      = stream.shard_count
      retention_period = stream.retention_period
      encryption_type  = stream.encryption_type
    }
  }
}
