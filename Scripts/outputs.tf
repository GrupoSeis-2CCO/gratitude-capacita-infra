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
  value       = "sudo mysql -u root -p'${mysql_root_password}' Capacita"
  description = "Comando MySQL para conectar no banco local (dentro da EC2 backend)"
  sensitive   = false
}
