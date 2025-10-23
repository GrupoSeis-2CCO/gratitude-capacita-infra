# ====================================
# GRAFANA NA AWS (ECS FARGATE)
# ====================================
# Configurações do Grafana rodando em ECS Fargate

# VPC para o Grafana (usando VPC padrão simplificado)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group para Grafana
resource "aws_security_group" "grafana_sg" {
  name_prefix = "grafana-sg"
  vpc_id      = data.aws_vpc.default.id

  # HTTP access
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Grafana Security Group"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "grafana_cluster" {
  name = "grafana-gratitude-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "Grafana Cluster"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "grafana_task" {
  family                   = "grafana-gratitude"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = data.aws_iam_role.lab_role.arn
  task_role_arn           = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([
    {
      name  = "grafana"
      image = "grafana/grafana:latest"
      
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "GF_SECURITY_ADMIN_PASSWORD"
          value = "gratitude2025"
        },
        {
          name  = "GF_INSTALL_PLUGINS"
          value = "grafana-athena-datasource"
        },
        {
          name  = "AWS_DEFAULT_REGION"
          value = "us-east-1"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.grafana_logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }

      essential = true
    }
  ])

  tags = {
    Name = "Grafana Task Definition"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "grafana_logs" {
  name              = "/ecs/grafana-gratitude-2025"
  retention_in_days = 7

  tags = {
    Name = "Grafana Logs"
  }
}

# ECS Service
resource "aws_ecs_service" "grafana_service" {
  name            = "grafana-gratitude-service-2025"
  cluster         = aws_ecs_cluster.grafana_cluster.id
  task_definition = aws_ecs_task_definition.grafana_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.grafana_sg.id]
    assign_public_ip = true
  }

  tags = {
    Name = "Grafana Service"
  }
}