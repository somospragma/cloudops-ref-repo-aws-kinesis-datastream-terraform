# =============================================================================
# Outputs del Root/Sample (PC-IAC-007)
# =============================================================================

# -----------------------------------------------------------------------------
# ARNs de los Streams
# -----------------------------------------------------------------------------
output "stream_arns" {
  description = "Mapa de ARNs de los Kinesis Data Streams, indexado por clave."
  value       = module.kinesis_streams.stream_arns
}

output "stream_arns_list" {
  description = "Lista de ARNs de todos los Kinesis Data Streams."
  value       = module.kinesis_streams.stream_arns_list
}

# -----------------------------------------------------------------------------
# Nombres de los Streams
# -----------------------------------------------------------------------------
output "stream_names" {
  description = "Mapa de nombres de los Kinesis Data Streams, indexado por clave."
  value       = module.kinesis_streams.stream_names
}

output "stream_names_list" {
  description = "Lista de nombres de todos los Kinesis Data Streams."
  value       = module.kinesis_streams.stream_names_list
}

# -----------------------------------------------------------------------------
# IDs de los Streams
# -----------------------------------------------------------------------------
output "stream_ids" {
  description = "Mapa de IDs de los Kinesis Data Streams, indexado por clave."
  value       = module.kinesis_streams.stream_ids
}

# -----------------------------------------------------------------------------
# Información de Capacidad
# -----------------------------------------------------------------------------
output "stream_shard_counts" {
  description = "Mapa de conteo de shards por stream."
  value       = module.kinesis_streams.stream_shard_counts
}

output "stream_retention_periods" {
  description = "Mapa de períodos de retención (horas) por stream."
  value       = module.kinesis_streams.stream_retention_periods
}

# -----------------------------------------------------------------------------
# Resumen Completo
# -----------------------------------------------------------------------------
output "streams_summary" {
  description = "Resumen completo de todos los Kinesis Data Streams creados."
  value       = module.kinesis_streams.streams_summary
}

# -----------------------------------------------------------------------------
# Información de Contexto
# -----------------------------------------------------------------------------
output "kms_key_arn" {
  description = "ARN de la KMS key usada para cifrado de los streams."
  value       = data.aws_kms_key.kinesis.arn
}

output "governance_prefix" {
  description = "Prefijo de gobernanza usado para nomenclatura."
  value       = local.governance_prefix
}
