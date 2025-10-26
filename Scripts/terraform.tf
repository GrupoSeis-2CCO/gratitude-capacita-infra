# ====================================
# TERRAFORM CONFIGURATION
# ====================================
# Configurações do Terraform e Providers

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# NOTE: Removed the `data "aws_iam_role" "lab_role"` data source because
# some execution identities have an explicit deny for iam:GetRole which
# causes `terraform plan`/`apply` to fail with 403. Use the variable
# `var.lab_role_arn` (declared in `variaveis.tf`) to pass the ARN of the
# role you want to reference instead of querying it at plan time.