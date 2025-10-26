variable "cidr_qualquer_ip" {
  description = "Qualquer IP do Mundo"
  type        = string
  default     = "0.0.0.0/0"
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

variable "admin_email" {
  description = "Email do administrador para notificações de backup (SES sender/recipient)"
  type        = string
  default     = "admin@example.com"
}

variable "db_name" {
  description = "Nome do banco de dados MySQL"
  type        = string
  default     = "capacita"
}

variable "db_user" {
  description = "Usuário do banco de dados usado pela aplicação"
  type        = string
  default     = "capacita_app"
}

variable "db_password" {
  description = "Senha do usuário do banco de dados (definir no terraform.tfvars ou usar default)"
  type        = string
  sensitive   = true
  default     = "#Gfcapacita123"
}

# SMTP para envio de notificacoes (relay SMTP, ex: Gmail App Password)
variable "smtp_host" {
  description = "SMTP relay host (ex: smtp.gmail.com)"
  type        = string
  default     = "smtp.gmail.com"
}

variable "smtp_port" {
  description = "SMTP relay port"
  type        = number
  default     = 587
}

variable "smtp_user" {
  description = "Usuario SMTP (ex: email)"
  type        = string
  default     = ""
}

variable "smtp_pass" {
  description = "Senha do SMTP (app password). Sensível."
  type        = string
  sensitive   = true
  default     = ""
}

variable "smtp_from" {
  description = "Endereço FROM para emails enviados pelo sistema"
  type        = string
  default     = "no-reply@example.com"
}

# VPC e subnets para Grafana (se você não puder usar data sources por falta de permissões)
variable "vpc_id" {
  description = "ID da VPC onde o Grafana será criado (ex: vpc-0123456789abcdef0)"
  type        = string
  default     = ""
}

variable "grafana_subnets" {
  description = "Lista de subnet IDs para o Grafana (Fargate)"
  type        = list(string)
  default     = []
}

variable "lab_role_arn" {
  description = "ARN do IAM Role a ser usado como execution/task role para o Grafana (ex: arn:aws:iam::123456:role/RoleName)"
  type        = string
  default     = ""
}

variable "backup_bucket_name" {
  description = "(Opcional) Nome de um bucket S3 existente para armazenar backups. Se vazio, o Terraform criará um novo bucket."
  type        = string
  default     = ""
}

variable "instance_profile_name" {
  description = "(Opcional) Nome de um instance profile IAM existente para usar na EC2. Se vazio, o Terraform criará um instance profile associado à role gerada." 
  type        = string
  default     = ""
}
