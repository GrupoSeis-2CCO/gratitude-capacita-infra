variable "cidr_qualquer_ip"{
    description = "Qualquer IP do Mundo"
    type = string
    default     = "0.0.0.0/0"
}

variable "cidr_publica" {
  description = "Bloco CIDR para subnet pública"
  type        = string
  default     = "10.0.0.0/22" # IPs de 10.0.0.0 a 10.0.3.255
}

variable "cidr_privada" {
  description = "Bloco CIDR para subnet privada"
  type        = string
  default     = "10.0.4.0/22" # IPs de 10.0.4.0 a 10.0.7.255
}
