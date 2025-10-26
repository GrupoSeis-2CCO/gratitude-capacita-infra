variable "cidr_qualquer_ip" {
    description = "Qualquer IP do Mundo"
    type = string
    default = "0.0.0.0/0"
}

variable "cidr_publica_1" {
  description = "Bloco CIDR para subnet publica 1"
  type        = string
  default     = "10.0.0.0/24" # IPs de 10.0.0.0 a 10.0.0.255
}

variable "cidr_publica_2" {
  description = "Bloco CIDR para subnet publica 2"
  type        = string
  default     = "10.0.1.0/24" # IPs de 10.0.1.0 a 10.0.1.255
}

variable "cidr_privada" {
  description = "Bloco CIDR para subnet privada"
  type        = string
  default     = "10.0.2.0/24" # IPs de 10.0.2.0 a 10.0.2.255
}

variable "mysql_root_password" {
  description = "Senha do MySQL root (definir no terraform.tfvars)"
  type        = string
  sensitive   = true
}

variable "database_user" {
  description = "Usuário do banco de dados da aplicação (definir no terraform.tfvars)"
  type        = string
  sensitive   = true
  default     = "capacita_app"
}

variable "database_password" {
  description = "Senha do usuário do banco de dados (definir no terraform.tfvars)"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "Secret para assinar tokens JWT (definir no terraform.tfvars - min 32 chars)"
  type        = string
  sensitive   = true
}

# ====================================
# VARIÁVEIS DO PIPELINE DE DADOS
# ====================================

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "projeto-pi-dados"
}

variable "environment" {
  description = "Ambiente (dev, prod)"
  type        = string
  default     = "dev"
}
