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

# Data source para LabRole (AWS Academy)
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# Data source para região atual
data "aws_region" "current" {}