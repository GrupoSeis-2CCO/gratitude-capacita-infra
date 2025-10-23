# ====================================
# OUTPUTS ORIGINAIS DO PROJETO
# ====================================

# Outputs uteis para configuracao

output "bastion_public_ip" {
  value       = aws_instance.ec2_publica_gratitude_1.public_ip
  description = "IP publico do Bastion Host para SSH"
}

output "backend_private_ip" {
  value       = aws_instance.ec2_privada_gratitude_backend.private_ip
  description = "IP privado da EC2 Backend"
}

output "deploy_bucket_name" {
  value       = aws_s3_bucket.deploy.id
  description = "Nome do bucket S3 para deploy"
}

output "bronze_bucket_name" {
  value       = aws_s3_bucket.bronze.id
  description = "Nome do bucket Bronze"
}

output "silver_bucket_name" {
  value       = aws_s3_bucket.silver.id
  description = "Nome do bucket Silver"
}

output "gold_bucket_name" {
  value       = aws_s3_bucket.gold.id
  description = "Nome do bucket Gold"
}

output "ssh_bastion_command" {
  value       = "ssh -i keys/vockey.pem ubuntu@${aws_instance.ec2_publica_gratitude_1.public_ip}"
  description = "Comando SSH para conectar no Bastion"
}

output "ssh_backend_command" {
  value       = "ssh -i keys/vockey.pem -J ubuntu@${aws_instance.ec2_publica_gratitude_1.public_ip} ubuntu@${aws_instance.ec2_privada_gratitude_backend.private_ip}"
  description = "Comando SSH para conectar no Backend via bastion"
}

output "mysql_local_command" {
  value       = "sudo mysql -u root -p'${var.mysql_root_password}' capacita"
  description = "Comando MySQL para conectar no banco local (dentro da EC2 backend)"
  sensitive   = true
}

# ====================================
# OUTPUTS DO PIPELINE DE DADOS
# ====================================

output "s3_buckets" {
  description = "S3 buckets criados para pipeline de dados"
  value = {
    bronze = aws_s3_bucket.bronze_bucket.id
    silver = aws_s3_bucket.silver_bucket.id
    gold   = aws_s3_bucket.gold_bucket.id
  }
}

output "lambda_functions" {
  description = "Funções Lambda criadas"
  value = {
    bronze_to_silver = aws_lambda_function.bronze_to_silver.function_name
    silver_to_gold   = aws_lambda_function.silver_to_gold.function_name
  }
}

output "aws_console_urls" {
  description = "URLs do console AWS"
  value = {
    bronze_bucket    = "https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.bronze_bucket.id}"
    silver_bucket    = "https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.silver_bucket.id}"
    gold_bucket      = "https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.gold_bucket.id}"
    lambda_functions = "https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions"
    cloudwatch_logs  = "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups"
  }
}

output "pipeline_info" {
  description = "Informações do pipeline"
  value = {
    architecture    = "Bronze → Silver (One Big Table) → Gold (Grafana Tables)"
    execution_mode  = "Manual Lambda execution (AWS Academy Lab compatible)"
    memory_size     = "2048 MB per Lambda"
    timeout         = "15 minutes per Lambda"
    optimization    = "Sample-based processing for performance"
  }
}

output "athena_info" {
  description = "Informações do Athena"
  value = {
    database_name = aws_glue_catalog_database.gratitude_analytics.name
    tables = {
      one_big_table = aws_glue_catalog_table.one_big_table.name
      items = aws_glue_catalog_table.items_table.name
      users = aws_glue_catalog_table.users_table.name
      kpis  = aws_glue_catalog_table.kpis_table.name
    }
    athena_results_bucket = aws_s3_bucket.athena_results.bucket
  }
}

output "grafana_info" {
  description = "Informações do Grafana"
  value = {
    cluster_name = aws_ecs_cluster.grafana_cluster.name
    service_name = aws_ecs_service.grafana_service.name
    admin_password = "gratitude2025"
    note = "Aguarde 2-3 minutos para o Grafana inicializar. Acesse via ECS console para obter o IP público."
  }
}
