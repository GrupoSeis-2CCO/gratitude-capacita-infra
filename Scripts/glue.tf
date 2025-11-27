# ====================================
# AWS GLUE DATA CATALOG & ATHENA
# ====================================
# Configurações do AWS Glue Data Catalog para Athena + Grafana

# Database do Glue para Athena
resource "aws_glue_catalog_database" "gratitude_analytics" {
  name = "gratitude_analytics_2025"
  
  description = "Database para análise de dados de gratidão - Athena + Grafana"
}

# Bucket para resultados Athena
resource "aws_s3_bucket" "athena_results" {
  bucket        = "gratitude-athena-results-nov26"
  force_destroy = true

  tags = {
    Name        = "Athena Query Results"
    Environment = var.environment
    Purpose     = "Store Athena query results"
  }
}

# Tabela ONE BIG TABLE no Glue Data Catalog (Silver Layer)
resource "aws_glue_catalog_table" "one_big_table" {
  name          = "one_big_table"
  database_name = aws_glue_catalog_database.gratitude_analytics.name
  
  description = "Tabela unificada com todos os dados do Silver layer"
  
  table_type = "EXTERNAL_TABLE"
  
  parameters = {
    "classification" = "csv"
    "delimiter"      = ","
    "skip.header.line.count" = "1"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.silver_bucket.bucket}/silver/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
        "skip.header.line.count" = "1"
      }
    }
    
    columns {
      name = "user_id"
      type = "bigint"
    }
    
    columns {
      name = "item_id"
      type = "bigint"
    }
    
    columns {
      name = "record_type"
      type = "string"
    }
    
    columns {
      name = "implicit_rating"
      type = "double"
    }
    
    columns {
      name = "explicit_rating"
      type = "double"
    }
    
    columns {
      name = "user_language"
      type = "string"
    }
    
    columns {
      name = "item_name"
      type = "string"
    }
    
    columns {
      name = "item_type"
      type = "string"
    }
    
    columns {
      name = "session_duration"
      type = "string"
    }
    
    columns {
      name = "activity_type"
      type = "string"
    }
    
    columns {
      name = "progress_percent"
      type = "string"
    }
    
    columns {
      name = "created_at"
      type = "timestamp"
    }
    
    columns {
      name = "data_source"
      type = "string"
    }
  }
}

# Tabela Items no Glue Data Catalog
resource "aws_glue_catalog_table" "items_table" {
  name          = "items"
  database_name = aws_glue_catalog_database.gratitude_analytics.name
  
  description = "Tabela de itens processados do Gold layer"
  
  table_type = "EXTERNAL_TABLE"
  
  parameters = {
    "classification" = "csv"
    "delimiter"      = ","
    "skip.header.line.count" = "1"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.gold_bucket.bucket}/gold/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
        "skip.header.line.count" = "1"
      }
    }
    
    columns {
      name = "item_id"
      type = "bigint"
    }
    
    columns {
      name = "item_name"
      type = "string"
    }
    
    columns {
      name = "item_type"
      type = "string"
    }
    
    columns {
      name = "item_difficulty"
      type = "string"
    }
    
    columns {
      name = "item_language"
      type = "string"
    }
    
    columns {
      name = "total_views"
      type = "bigint"
    }
  }
}

# Tabela Users no Glue Data Catalog
resource "aws_glue_catalog_table" "users_table" {
  name          = "users"
  database_name = aws_glue_catalog_database.gratitude_analytics.name
  
  description = "Tabela de usuários processados do Gold layer"
  
  table_type = "EXTERNAL_TABLE"
  
  parameters = {
    "classification" = "csv"
    "delimiter"      = ","
    "skip.header.line.count" = "1"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.gold_bucket.bucket}/gold/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
        "skip.header.line.count" = "1"
      }
    }
    
    columns {
      name = "user_id"
      type = "bigint"
    }
    
    columns {
      name = "user_job"
      type = "string"
    }
    
    columns {
      name = "user_language"
      type = "string"
    }
    
    columns {
      name = "total_interactions"
      type = "bigint"
    }
  }
}

# Tabela KPIs no Glue Data Catalog
resource "aws_glue_catalog_table" "kpis_table" {
  name          = "kpis"
  database_name = aws_glue_catalog_database.gratitude_analytics.name
  
  description = "Tabela de KPIs do Gold layer"
  
  table_type = "EXTERNAL_TABLE"
  
  parameters = {
    "classification" = "csv"
    "delimiter"      = ","
    "skip.header.line.count" = "1"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.gold_bucket.bucket}/gold/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
        "skip.header.line.count" = "1"
      }
    }
    
    columns {
      name = "metric"
      type = "string"
    }
    
    columns {
      name = "value"
      type = "bigint"
    }
    
    columns {
      name = "date"
      type = "date"
    }
  }
}

# ====================================
# TABELAS GLUE PARA DADOS SINTÉTICOS
# ====================================

# Tabela para sessões de usuários
resource "aws_glue_catalog_table" "user_sessions_table" {
  name          = "user_sessions"
  database_name = aws_glue_catalog_database.gratitude_analytics.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "csv"
    "delimiter"      = ","
    "skip.header.line.count" = "1"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.gold_bucket.bucket}/gold/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
        "skip.header.line.count" = "1"
      }
    }
    
    columns {
      name = "session_id"
      type = "string"
    }
    
    columns {
      name = "user_id"
      type = "bigint"
    }
    
    columns {
      name = "session_start"
      type = "timestamp"
    }
    
    columns {
      name = "duration_minutes"
      type = "bigint"
    }
    
    columns {
      name = "pages_visited"
      type = "bigint"
    }
    
    columns {
      name = "device_type"
      type = "string"
    }
  }
}

# Tabela para ratings/avaliações
resource "aws_glue_catalog_table" "ratings_table" {
  name          = "ratings"
  database_name = aws_glue_catalog_database.gratitude_analytics.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "csv"
    "delimiter"      = ","
    "skip.header.line.count" = "1"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.gold_bucket.bucket}/gold/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
        "skip.header.line.count" = "1"
      }
    }
    
    columns {
      name = "rating_id"
      type = "string"
    }
    
    columns {
      name = "user_id"
      type = "bigint"
    }
    
    columns {
      name = "item_id"
      type = "bigint"
    }
    
    columns {
      name = "rating"
      type = "bigint"
    }
    
    columns {
      name = "rating_date"
      type = "timestamp"
    }
    
    columns {
      name = "has_comment"
      type = "boolean"
    }
    
    columns {
      name = "comment_length"
      type = "bigint"
    }
  }
}

# Tabela para progresso dos cursos
resource "aws_glue_catalog_table" "course_progress_table" {
  name          = "course_progress"
  database_name = aws_glue_catalog_database.gratitude_analytics.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "csv"
    "delimiter"      = ","
    "skip.header.line.count" = "1"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.gold_bucket.bucket}/gold/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
        "skip.header.line.count" = "1"
      }
    }
    
    columns {
      name = "progress_id"
      type = "string"
    }
    
    columns {
      name = "user_id"
      type = "bigint"
    }
    
    columns {
      name = "item_id"
      type = "bigint"
    }
    
    columns {
      name = "progress_percent"
      type = "double"
    }
    
    columns {
      name = "status"
      type = "string"
    }
    
    columns {
      name = "time_spent_minutes"
      type = "bigint"
    }
    
    columns {
      name = "start_date"
      type = "timestamp"
    }
    
    columns {
      name = "last_activity"
      type = "timestamp"
    }
    
    columns {
      name = "attempts"
      type = "bigint"
    }
  }
}

# Tabela para métricas de engajamento diárias
resource "aws_glue_catalog_table" "daily_engagement_table" {
  name          = "daily_engagement"
  database_name = aws_glue_catalog_database.gratitude_analytics.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "csv"
    "delimiter"      = ","
    "skip.header.line.count" = "1"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.gold_bucket.bucket}/gold/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
        "skip.header.line.count" = "1"
      }
    }
    
    columns {
      name = "date"
      type = "date"
    }
    
    columns {
      name = "daily_active_users"
      type = "bigint"
    }
    
    columns {
      name = "page_views"
      type = "bigint"
    }
    
    columns {
      name = "avg_session_duration_minutes"
      type = "double"
    }
    
    columns {
      name = "bounce_rate"
      type = "double"
    }
    
    columns {
      name = "new_registrations"
      type = "bigint"
    }
    
    columns {
      name = "course_completions"
      type = "bigint"
    }
  }
}