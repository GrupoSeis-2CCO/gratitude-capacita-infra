# outputs.tf - Outputs importantes

output "load_balancer_url" {
  description = "URL da aplicação"
  value       = "http://${aws_lb.main.dns_name}"
}

output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "database_endpoint" {
  description = "Endpoint do banco de dados"
  value       = aws_db_instance.main.endpoint
}

output "s3_buckets" {
  description = "Buckets S3 criados"
  value = {
    client_data  = aws_s3_bucket.client_data.bucket
    trusted_data = aws_s3_bucket.trusted_data.bucket
    raw_data     = aws_s3_bucket.raw_data.bucket
  }
}

output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = aws_ecs_cluster.main.name
}