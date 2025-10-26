# ====================================
# LAMBDA FUNCTIONS
# ====================================
# Funções Lambda para pipeline Bronze → Silver → Gold

# Lambda Bronze → Silver (One Big Table)
data "archive_file" "lambda_bronze_silver_zip" {
  type        = "zip"
  output_path = "lambda_bronze_to_silver.zip"
  
  source_file  = "lambda_bronze_to_silver.py"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "bronze_to_silver" {
  filename         = data.archive_file.lambda_bronze_silver_zip.output_path
  function_name    = "${var.project_name}-bronze-to-silver-${var.environment}"
  role            = var.lab_role_arn
  handler         = "lambda_bronze_to_silver.lambda_handler"
  runtime         = "python3.11"
  timeout         = 900   # 15 minutos (máximo AWS Lambda)
  memory_size     = 2048  # 2GB para processamento de dados grandes

  source_code_hash = data.archive_file.lambda_bronze_silver_zip.output_base64sha256

  # layers = []  # Comentado para AWS Academy Lab - Lambdas usarão apenas boto3

  environment {
    variables = {
      BRONZE_BUCKET = aws_s3_bucket.bronze_bucket.id
      SILVER_BUCKET = aws_s3_bucket.silver_bucket.id
      ENVIRONMENT   = var.environment
    }
  }

  tags = {
    Name        = "Bronze to Silver Processor"
    Environment = var.environment
  }
}

# Lambda Silver → Gold (Tabelas Grafana)
data "archive_file" "lambda_silver_gold_zip" {
  type        = "zip"
  output_path = "lambda_silver_to_gold.zip"
  
  source_file  = "lambda_silver_to_gold.py"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "silver_to_gold" {
  filename         = data.archive_file.lambda_silver_gold_zip.output_path
  function_name    = "${var.project_name}-silver-to-gold-${var.environment}"
  role            = var.lab_role_arn
  handler         = "lambda_silver_to_gold.lambda_handler"
  runtime         = "python3.11"
  timeout         = 900   # 15 minutos (máximo AWS Lambda)
  memory_size     = 2048  # 2GB para processamento de dados grandes

  source_code_hash = data.archive_file.lambda_silver_gold_zip.output_base64sha256

  # layers = []  # Comentado para AWS Academy Lab - Lambdas usarão apenas boto3

  environment {
    variables = {
      SILVER_BUCKET = aws_s3_bucket.silver_bucket.id
      GOLD_BUCKET   = aws_s3_bucket.gold_bucket.id
      ENVIRONMENT   = var.environment
    }
  }

  tags = {
    Name        = "Silver to Gold Processor"
    Environment = var.environment
  }
}