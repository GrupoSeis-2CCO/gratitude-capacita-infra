"""
AWS LAMBDA: BRONZE → SILVER (AWS ACADEMY COMPATIBLE)
===================================================
Versão simplificada que funciona apenas com boto3
Processa CSVs e cria estrutura básica Silver
"""

import json
import boto3
import csv
import io
import logging
from datetime import datetime

# Configurar logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Handler principal da Lambda Bronze → Silver
    """
    try:
        logger.info("🚀 INICIANDO LAMBDA BRONZE → SILVER")
        
        # Obter informações do evento S3
        if 'Records' in event:
            # Trigger S3 - quando um novo arquivo é adicionado
            for record in event['Records']:
                bucket_name = record['s3']['bucket']['name']
                object_key = record['s3']['object']['key']
                
                logger.info(f"📁 Novo arquivo detectado: s3://{bucket_name}/{object_key}")
            
            # Sempre reprocessar TODOS os arquivos para criar nova ONE BIG TABLE
            bucket_name = event['Records'][0]['s3']['bucket']['name']
            process_all_bronze_files(bucket_name)
        else:
            # Trigger manual
            bucket_name = event.get('bucket_name')
            if not bucket_name:
                raise ValueError("bucket_name obrigatório para trigger manual")
            
            # Processar todos os arquivos Bronze e criar ONE BIG TABLE
            process_all_bronze_files(bucket_name)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Bronze → Silver processado com sucesso',
                'timestamp': datetime.now().isoformat()
            })
        }
        
    except Exception as e:
        logger.error(f"❌ ERRO NA LAMBDA: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'message': 'Falha no processamento Bronze → Silver'
            })
        }

# Função process_bronze_file removida - agora processamos todos os arquivos juntos para criar ONE BIG TABLE

def process_all_bronze_files(bronze_bucket):
    """
    Processa todos os arquivos CSV do Bronze e cria ONE BIG TABLE
    """
    s3_client = boto3.client('s3')
    
    try:
        # Listar arquivos do Bronze
        response = s3_client.list_objects_v2(
            Bucket=bronze_bucket,
            Prefix='bronze/'
        )
        
        if 'Contents' not in response:
            logger.warning("⚠️ Nenhum arquivo encontrado no Bronze")
            return
        
        csv_files = [obj['Key'] for obj in response['Contents'] 
                    if obj['Key'].endswith('.csv')]
        
        logger.info(f"📋 Encontrados {len(csv_files)} arquivos CSV")
        
        # Carregar todos os dados Bronze
        bronze_data = {}
        for file_key in csv_files:
            file_name = file_key.split('/')[-1].replace('.csv', '')
            bronze_data[file_name] = load_csv_data(s3_client, bronze_bucket, file_key)
        
        # Criar ONE BIG TABLE
        one_big_table = create_one_big_table(bronze_data)
        
        if one_big_table:
            # Salvar ONE BIG TABLE no Silver
            silver_bucket = bronze_bucket.replace('bronze', 'silver')
            save_one_big_table(s3_client, silver_bucket, one_big_table)
            logger.info("✅ ONE BIG TABLE criada com sucesso!")
        
    except Exception as e:
        logger.error(f"❌ Erro ao processar arquivos Bronze: {e}")
        raise

# Função create_simple_consolidation removida - agora usamos ONE BIG TABLE diretamente

def load_csv_data(s3_client, bucket, key):
    """
    Carrega dados CSV do S3 como lista de dicionários
    """
    try:
        response = s3_client.get_object(Bucket=bucket, Key=key)
        csv_content = response['Body'].read().decode('utf-8')
        rows = list(csv.DictReader(io.StringIO(csv_content)))
        logger.info(f"✅ Carregado {key}: {len(rows)} registros")
        return rows
    except Exception as e:
        logger.error(f"❌ Erro ao carregar {key}: {e}")
        return []

def create_one_big_table(bronze_data):
    """
    Cria ONE BIG TABLE otimizada com dados originais + sintéticos
    """
    logger.info("🔄 CRIANDO ONE BIG TABLE OTIMIZADA (ORIGINAIS + SINTÉTICOS)...")
    
    # Separar dados ORIGINAIS por tipo - usar apenas amostra para evitar timeout
    users_en = bronze_data.get('users_en', [])[:1000] if bronze_data.get('users_en') else []
    users_fr = bronze_data.get('users_fr', [])[:1000] if bronze_data.get('users_fr') else []
    items_en = bronze_data.get('items_en', [])[:1000] if bronze_data.get('items_en') else []
    items_fr = bronze_data.get('items_fr', [])[:1000] if bronze_data.get('items_fr') else []
    explicit_en = bronze_data.get('explicit_ratings_en', [])[:5000] if bronze_data.get('explicit_ratings_en') else []
    explicit_fr = bronze_data.get('explicit_ratings_fr', [])[:5000] if bronze_data.get('explicit_ratings_fr') else []
    implicit_en = bronze_data.get('implicit_ratings_en', [])[:5000] if bronze_data.get('implicit_ratings_en') else []
    implicit_fr = bronze_data.get('implicit_ratings_fr', [])[:5000] if bronze_data.get('implicit_ratings_fr') else []
    
    # Dados SINTÉTICOS FOCADOS - usar amostra para performance
    user_sessions_synthetic = bronze_data.get('user_sessions_synthetic', [])[:2000] if bronze_data.get('user_sessions_synthetic') else []
    user_activities_synthetic = bronze_data.get('user_activities_synthetic', []) if bronze_data.get('user_activities_synthetic') else []
    user_progress_synthetic = bronze_data.get('user_progress_synthetic', [])[:2000] if bronze_data.get('user_progress_synthetic') else []
    
    logger.info(f"📊 Processando dados:")
    logger.info(f"   • Ratings implícitos: {len(implicit_en + implicit_fr)}")
    logger.info(f"   • Sessões sintéticas: {len(user_sessions_synthetic)}")
    logger.info(f"   • Atividades sintéticas: {len(user_activities_synthetic)}")
    logger.info(f"   • Progress sintético: {len(user_progress_synthetic)}")
    
    # Criar mapeamentos completos
    users_map = {}
    items_map = {}
    
    # Mapear usuários com TODAS as colunas (EN + FR)
    for user in users_en + users_fr:
        user_id = user.get('user_id')
        if user_id:
            users_map[user_id] = {
                'user_id': user_id,
                'user_job': user.get('job', ''),
                'user_language': 'EN' if user in users_en else 'FR'
            }
    
    # Mapear itens com TODAS as colunas (EN + FR)  
    for item in items_en + items_fr:
        item_id = item.get('item_id')
        if item_id:
            items_map[item_id] = {
                'item_id': item_id,
                'item_language': item.get('language', ''),
                'item_name': item.get('name', ''),
                'item_nb_views': item.get('nb_views', '0'),
                'item_description': item.get('description', ''),
                'item_created_at': item.get('created_at', ''),
                'item_difficulty': item.get('Difficulty', ''),
                'item_job': item.get('Job', ''),
                'item_software': item.get('Software', ''),
                'item_theme': item.get('Theme', ''),
                'item_duration': item.get('duration', ''),
                'item_type': item.get('type', ''),
                'item_source_language': 'EN' if item in items_en else 'FR'
            }
    
    # Criar mapeamento completo de ratings explícitos
    explicit_ratings = {}
    for rating in explicit_en + explicit_fr:
        user_id = rating.get('user_id')
        item_id = rating.get('item_id')
        if user_id and item_id:
            key = f"{user_id}_{item_id}"
            explicit_ratings[key] = {
                'explicit_user_id': rating.get('user_id', ''),
                'explicit_item_id': rating.get('item_id', ''),
                'explicit_watch_percentage': rating.get('watch_percentage', '0'),
                'explicit_created_at': rating.get('created_at', ''),
                'explicit_rating': rating.get('rating', '0'),
                'explicit_source_language': 'EN' if rating in explicit_en else 'FR'
            }
    
    # Base da ONE BIG TABLE: ratings implícitos + dados sintéticos
    one_big_table = []
    
    # 1. PROCESSAR RATINGS IMPLÍCITOS (dados originais) - VERSÃO SIMPLIFICADA
    for implicit in implicit_en + implicit_fr:
        user_id = implicit.get('user_id')
        item_id = implicit.get('item_id')
        
        if user_id and item_id:
            # Criar registro super simplificado
            record = {
                'user_id': user_id,
                'item_id': item_id,
                'record_type': 'implicit_rating',
                'implicit_rating': '1',
                'explicit_rating': '',
                'user_language': '',
                'item_name': '',
                'item_type': '',
                'session_duration': '',
                'activity_type': 'implicit_view',
                'progress_percent': '',
                'created_at': implicit.get('created_at', ''),
                'data_source': 'csv_original'
            }
            
            # Adicionar à tabela
            one_big_table.append(record)
    
    # 2. PROCESSAR DADOS SINTÉTICOS - USER SESSIONS
    logger.info("🤖 Adicionando dados sintéticos de user_sessions...")
    for session in user_sessions_synthetic:
        record = {
            'user_id': session.get('user_id', ''),
            'item_id': '',
            'record_type': 'user_session',
            'implicit_rating': '',
            'explicit_rating': '',
            'user_language': '',
            'item_name': '',
            'item_type': '',
            'session_duration': session.get('duration_minutes', ''),
            'activity_type': 'session',
            'progress_percent': '',
            'created_at': session.get('session_start', ''),
            'data_source': 'synthetic_data'
        }
        one_big_table.append(record)
    
    # 3. PROCESSAR DADOS SINTÉTICOS - USER ACTIVITIES
    logger.info("🤖 Adicionando dados sintéticos de user_activities...")
    for activity in user_activities_synthetic:
        record = {
            'user_id': activity.get('user_id', ''),
            'item_id': activity.get('item_id', ''),
            'record_type': 'user_activity',
            'implicit_rating': '',
            'explicit_rating': '',
            'user_language': '',
            'item_name': '',
            'item_type': '',
            'session_duration': activity.get('time_spent_minutes', ''),
            'activity_type': activity.get('activity_type', ''),
            'progress_percent': activity.get('completion_percentage', ''),
            'created_at': activity.get('activity_date', ''),
            'data_source': 'synthetic_data'
        }
        one_big_table.append(record)
    
    # 4. PROCESSAR DADOS SINTÉTICOS - USER PROGRESS
    logger.info("🤖 Adicionando dados sintéticos de user_progress...")
    for progress in user_progress_synthetic:
        record = {
            'user_id': progress.get('user_id', ''),
            'item_id': progress.get('item_id', ''),
            'record_type': 'user_progress',
            'implicit_rating': '',
            'explicit_rating': '',
            'user_language': '',
            'item_name': '',
            'item_type': '',
            'session_duration': progress.get('time_spent_minutes', ''),
            'activity_type': 'course_progress',
            'progress_percent': progress.get('progress_percent', ''),
            'created_at': progress.get('start_date', ''),
            'data_source': 'synthetic_data'
        }
        one_big_table.append(record)
    
    logger.info(f"✅ ONE BIG TABLE criada com DADOS SINTÉTICOS: {len(one_big_table)} registros")
    logger.info(f"   • Usuários únicos: {len(set(r['user_id'] for r in one_big_table if r.get('user_id')))}")
    logger.info(f"   • Itens únicos: {len(set(r['item_id'] for r in one_big_table if r.get('item_id')))}")
    logger.info(f"   • Com rating explícito: {sum(1 for r in one_big_table if r.get('explicit_rating', '') != '')}")
    
    return one_big_table

# Função create_synthetic_base_record removida - usando schema fixo simplificado

def save_one_big_table(s3_client, silver_bucket, one_big_table):
    """
    Salva ONE BIG TABLE no bucket Silver
    """
    if not one_big_table:
        logger.warning("⚠️ ONE BIG TABLE vazia - nada para salvar")
        return
    
    # Nome do arquivo - sempre usar o mesmo nome para compatibilidade
    silver_key = "silver/one_big_table.csv"
    
    # Schema fixo para garantir consistência
    fixed_fieldnames = [
        'user_id', 'item_id', 'record_type', 'implicit_rating', 'explicit_rating',
        'user_language', 'item_name', 'item_type', 'session_duration', 'activity_type',
        'progress_percent', 'created_at', 'data_source'
    ]
    
    # Criar CSV com schema fixo
    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=fixed_fieldnames, extrasaction='ignore')
    writer.writeheader()
    
    for row in one_big_table:
        # Garantir que todos os campos existem
        normalized_row = {}
        for field in fixed_fieldnames:
            normalized_row[field] = row.get(field, '')
        writer.writerow(normalized_row)
    
    csv_content = output.getvalue()
    
    # Salvar ONE BIG TABLE
    s3_client.put_object(
        Bucket=silver_bucket,
        Key=silver_key,
        Body=csv_content,
        ContentType='text/csv'
    )
    
    logger.info(f"💾 ONE BIG TABLE salva:")
    logger.info(f"   • s3://{silver_bucket}/{silver_key}")
    logger.info(f"   • Registros: {len(one_big_table)}")
    logger.info(f"   • Tamanho: {len(csv_content)} bytes")

def save_csv_to_s3(s3_client, bucket, key, rows):
    """
    Salva lista de dicionários como CSV no S3
    """
    if not rows:
        return
    
    # Criar CSV em memória
    output = io.StringIO()
    fieldnames = rows[0].keys()
    writer = csv.DictWriter(output, fieldnames=fieldnames)
    
    writer.writeheader()
    for row in rows:
        writer.writerow(row)
    
    # Upload para S3
    s3_client.put_object(
        Bucket=bucket,
        Key=key,
        Body=output.getvalue(),
        ContentType='text/csv'
    )

# Para testes locais
if __name__ == "__main__":
    test_event = {
        'bucket_name': 'projeto-pi-dados-bronze-test'
    }
    
    result = lambda_handler(test_event, {})
    print(json.dumps(result, indent=2))