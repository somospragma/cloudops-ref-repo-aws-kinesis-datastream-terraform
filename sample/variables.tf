# =============================================================================
# Variables de entrada del Root/Sample (PC-IAC-002)
# =============================================================================

# -----------------------------------------------------------------------------
# Variables de Gobernanza (Obligatorias) - PC-IAC-002, PC-IAC-003
# -----------------------------------------------------------------------------

variable "client" {
  description = "Nombre del cliente o unidad de negocio. Usado para nomenclatura y tagging."
  type        = string

  validation {
    condition     = length(var.client) > 0 && length(var.client) <= 10
    error_message = "La variable 'client' debe tener entre 1 y 10 caracteres."
  }
}

variable "project" {
  description = "Nombre del proyecto. Usado para nomenclatura y tagging."
  type        = string

  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 15
    error_message = "La variable 'project' debe tener entre 1 y 15 caracteres."
  }
}

variable "environment" {
  description = "Entorno de despliegue (dev, qa, pdn). Usado para nomenclatura y tagging."
  type        = string

  validation {
    condition     = contains(["dev", "qa", "stg", "pdn", "prod"], var.environment)
    error_message = "La variable 'environment' debe ser uno de: dev, qa, stg, pdn, prod."
  }
}

# -----------------------------------------------------------------------------
# Variable para KMS Key Alias (PC-IAC-020, PC-IAC-026)
# -----------------------------------------------------------------------------

variable "kms_key_alias" {
  description = "Alias de la KMS key para cifrado de Kinesis streams. Usado en data.tf para obtener el ARN."
  type        = string

  validation {
    condition     = can(regex("^alias/", var.kms_key_alias))
    error_message = "El 'kms_key_alias' debe comenzar con 'alias/'."
  }
}

# -----------------------------------------------------------------------------
# Variable de Configuración de Streams (PC-IAC-002, PC-IAC-009)
# -----------------------------------------------------------------------------

variable "streams_config" {
  description = <<-EOT
    Mapa de configuración para los Kinesis Data Streams.
    La clave del mapa se usa como identificador único y sufijo del nombre.
    
    NOTA: El campo 'kms_key_arn' debe dejarse vacío ("") para inyección dinámica
    desde data.tf siguiendo el patrón PC-IAC-026.
    
    Atributos:
    - stream_mode: (string) Modo de capacidad: "ON_DEMAND" o "PROVISIONED"
    - shard_count: (number) Número de shards (requerido solo si stream_mode = "PROVISIONED")
    - retention_period: (number) Período de retención en horas (24-8760). Default: 24
    - kms_key_arn: (string) Dejar vacío para inyección dinámica desde data.tf
    - enforce_consumer_deletion: (bool) Forzar eliminación de consumidores. Default: false
    - shard_level_metrics: (list) Métricas a nivel de shard. Default: []
    - additional_tags: (map) Tags adicionales específicos del stream
  EOT

  type = map(object({
    stream_mode               = optional(string, "ON_DEMAND")
    shard_count               = optional(number, null)
    retention_period          = optional(number, 24)
    kms_key_arn               = optional(string, "")
    enforce_consumer_deletion = optional(bool, false)
    shard_level_metrics       = optional(list(string), [])
    additional_tags           = optional(map(string), {})
  }))

  default = {}

  validation {
    condition = alltrue([
      for key, config in var.streams_config :
      contains(["ON_DEMAND", "PROVISIONED"], config.stream_mode)
    ])
    error_message = "El 'stream_mode' debe ser 'ON_DEMAND' o 'PROVISIONED'."
  }

  validation {
    condition = alltrue([
      for key, config in var.streams_config :
      config.stream_mode == "ON_DEMAND" || (config.stream_mode == "PROVISIONED" && config.shard_count != null && config.shard_count > 0)
    ])
    error_message = "Cuando stream_mode es 'PROVISIONED', shard_count debe ser mayor a 0."
  }

  validation {
    condition = alltrue([
      for key, config in var.streams_config :
      config.retention_period >= 24 && config.retention_period <= 8760
    ])
    error_message = "El 'retention_period' debe estar entre 24 y 8760 horas."
  }
}
