# =============================================================================
# Configuración de Providers (PC-IAC-005)
# =============================================================================
# 
# NOTA: Este módulo de referencia NO configura providers directamente.
# El provider debe ser inyectado desde el Módulo Raíz (IaC Root) mediante
# el alias obligatorio "aws.project".
#
# Ejemplo de inyección desde el Root:
#
#   module "kinesis_streams" {
#     source = "git::https://github.com/org/kinesis-stream-module.git?ref=v1.0.0"
#     
#     providers = {
#       aws.project = aws.principal
#     }
#     
#     # ... variables
#   }
#
# =============================================================================
