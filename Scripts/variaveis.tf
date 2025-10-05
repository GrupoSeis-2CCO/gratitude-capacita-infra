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
