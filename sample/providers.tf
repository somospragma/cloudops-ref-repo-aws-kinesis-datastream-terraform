# =============================================================================
# Configuración de Providers del Root/Sample (PC-IAC-005, PC-IAC-006)
# =============================================================================

terraform {
  # ---------------------------------------------------------------------------
  # Versión de Terraform (PC-IAC-006)
  # ---------------------------------------------------------------------------
  required_version = ">= 1.0.0"

  # ---------------------------------------------------------------------------
  # Providers requeridos (PC-IAC-006)
  # ---------------------------------------------------------------------------
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Provider AWS Principal (PC-IAC-005)
# -----------------------------------------------------------------------------
# El alias "principal" se mapea a "project" en el módulo.
# Esto permite que el Root controle la configuración del provider.
# -----------------------------------------------------------------------------
provider "aws" {
  alias  = "principal"
  region = "us-east-1"

  # ---------------------------------------------------------------------------
  # Tags por defecto aplicados a todos los recursos (PC-IAC-004)
  # ---------------------------------------------------------------------------
  default_tags {
    tags = {
      "managed-by"  = "terraform"
      "module"      = "kinesis-stream-sample"
      "client"      = "pragma"
      "project"     = "dataplatform"
      "environment" = "dev"
    }
  }
}
