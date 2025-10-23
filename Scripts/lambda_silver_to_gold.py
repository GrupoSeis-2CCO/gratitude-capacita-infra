import json
import boto3
import csv
import io
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        logger.info("INICIANDO LAMBDA SILVER TO GOLD")
        
        if 'Records' in event:
            bucket_name = event['Records'][0]['s3']['bucket']['name']
        else:
            bucket_name = event.get('bucket_name')
            if not bucket_name:
                raise ValueError("bucket_name obrigatorio")
        
        process_silver_to_gold(bucket_name)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Silver to Gold processado com sucesso',
                'timestamp': datetime.now().isoformat()
            })
        }
        
    except Exception as e:
        logger.error(f"ERRO: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'message': 'Falha no processamento Silver to Gold'
            })
        }

def process_silver_to_gold(silver_bucket):
    s3_client = boto3.client('s3')
    gold_bucket = silver_bucket.replace('silver', 'gold')
    
    try:
        logger.info("Carregando ONE BIG TABLE...")
        one_big_table = load_one_big_table_sample(s3_client, silver_bucket)
        
        if not one_big_table:
            logger.warning("ONE BIG TABLE vazia")
            return
        
        logger.info(f"Carregados {len(one_big_table)} registros")
        create_essential_gold_tables(s3_client, gold_bucket, one_big_table)
        
    except Exception as e:
        logger.error(f"Erro no processamento: {e}")
        raise

def load_one_big_table_sample(s3_client, silver_bucket):
    try:
        response = s3_client.get_object(
            Bucket=silver_bucket,
            Key='silver/one_big_table.csv'
        )
        
        csv_content = response['Body'].read().decode('utf-8')
        lines = csv_content.split('\n')
        
        if len(lines) > 1000:
            logger.info(f"Usando amostra de 1000 registros de {len(lines)} totais")
            csv_content = '\n'.join(lines[:1001])
        
        reader = csv.DictReader(io.StringIO(csv_content))
        return list(reader)
        
    except Exception as e:
        logger.error(f"Erro ao carregar ONE BIG TABLE: {e}")
        return []

def create_essential_gold_tables(s3_client, gold_bucket, data):
    # Tabelas originais
    users_table = create_users_table(data)
    save_gold_table(s3_client, gold_bucket, 'users', users_table)
    
    items_table = create_items_table(data)
    save_gold_table(s3_client, gold_bucket, 'items', items_table)
    
    kpis_table = create_kpis_table(data)
    save_gold_table(s3_client, gold_bucket, 'kpis', kpis_table)
    
    # Tabelas sintéticas
    logger.info("Criando tabelas sintéticas...")
    
    user_sessions_table = create_user_sessions_table(data)
    if user_sessions_table:
        save_gold_table(s3_client, gold_bucket, 'user_sessions', user_sessions_table)
    
    ratings_table = create_ratings_table(data)
    if ratings_table:
        save_gold_table(s3_client, gold_bucket, 'ratings', ratings_table)
    
    course_progress_table = create_course_progress_table(data)
    if course_progress_table:
        save_gold_table(s3_client, gold_bucket, 'course_progress', course_progress_table)
    
    user_activities_table = create_user_activities_table(data)
    if user_activities_table:
        save_gold_table(s3_client, gold_bucket, 'user_activities', user_activities_table)
    
    daily_engagement_table = create_daily_engagement_table(data)
    if daily_engagement_table:
        save_gold_table(s3_client, gold_bucket, 'daily_engagement', daily_engagement_table)
    
    logger.info("Todas as tabelas Gold criadas (originais + sintéticas)!")

def create_users_table(data):
    users = {}
    
    for row in data:
        user_id = row.get('user_id')
        if user_id and user_id not in users:
            users[user_id] = {
                'user_id': user_id,
                'user_job': row.get('user_job', ''),
                'user_language': row.get('user_language', ''),
                'total_interactions': 0
            }
        
        if user_id in users:
            users[user_id]['total_interactions'] += 1
    
    return list(users.values())

def create_items_table(data):
    items = {}
    
    for row in data:
        item_id = row.get('item_id')
        if item_id and item_id not in items:
            items[item_id] = {
                'item_id': item_id,
                'item_name': row.get('item_name', ''),
                'item_type': row.get('item_type', ''),
                'item_difficulty': row.get('item_difficulty', ''),
                'item_language': row.get('item_language', ''),
                'total_views': 0
            }
        
        if item_id in items:
            items[item_id]['total_views'] += 1
    
    return list(items.values())

def create_kpis_table(data):
    total_users = len(set(row.get('user_id') for row in data if row.get('user_id')))
    total_items = len(set(row.get('item_id') for row in data if row.get('item_id')))
    total_interactions = len(data)
    
    explicit_ratings = [row for row in data if row.get('has_explicit_rating') == '1']
    total_explicit = len(explicit_ratings)
    
    return [{
        'metric': 'total_users',
        'value': total_users,
        'date': datetime.now().strftime('%Y-%m-%d')
    }, {
        'metric': 'total_items', 
        'value': total_items,
        'date': datetime.now().strftime('%Y-%m-%d')
    }, {
        'metric': 'total_interactions',
        'value': total_interactions,
        'date': datetime.now().strftime('%Y-%m-%d')
    }, {
        'metric': 'explicit_ratings',
        'value': total_explicit,
        'date': datetime.now().strftime('%Y-%m-%d')
    }]

def create_user_sessions_table(data):
    """Extrai dados de sessões dos dados sintéticos"""
    sessions = []
    for row in data:
        if row.get('session_id') and row.get('record_type') == 'user_session':  # Dados de sessão
            sessions.append({
                'session_id': row.get('session_id', ''),
                'user_id': row.get('user_id', ''),
                'session_start': row.get('session_start', ''),
                'duration_minutes': row.get('duration_minutes', ''),
                'pages_visited': row.get('pages_visited', ''),
                'device_type': row.get('device_type', '')
            })
    return sessions

def create_ratings_table(data):
    """Extrai dados de ratings (originais + sintéticos)"""
    ratings = []
    for row in data:
        # Ratings explícitos originais
        if row.get('has_explicit_rating') == '1':
            ratings.append({
                'user_id': row.get('explicit_user_id', ''),
                'item_id': row.get('explicit_item_id', ''),
                'rating': row.get('explicit_rating', ''),
                'rating_date': row.get('explicit_created_at', ''),
                'watch_percentage': row.get('explicit_watch_percentage', ''),
                'source': 'explicit_original'
            })
        # Atividades sintéticas que podem ser consideradas ratings
        elif row.get('record_type') == 'user_activity' and row.get('activity_type') in ['rating', 'review']:
            ratings.append({
                'activity_id': row.get('activity_id', ''),
                'user_id': row.get('user_id', ''),
                'item_id': row.get('item_id', ''),
                'activity_type': row.get('activity_type', ''),
                'activity_date': row.get('activity_date', ''),
                'completion_percentage': row.get('completion_percentage', ''),
                'success': row.get('success', ''),
                'source': 'synthetic_activity'
            })
    return ratings

def create_course_progress_table(data):
    """Extrai dados de progresso dos dados sintéticos"""
    progress = []
    for row in data:
        if row.get('progress_id') and row.get('record_type') == 'user_progress':  # Dados de progresso
            progress.append({
                'progress_id': row.get('progress_id', ''),
                'user_id': row.get('user_id', ''),
                'item_id': row.get('item_id', ''),
                'progress_percent': row.get('progress_percent', ''),
                'status': row.get('status', ''),
                'time_spent_minutes': row.get('time_spent_minutes', ''),
                'start_date': row.get('start_date', ''),
                'last_activity': row.get('last_activity', ''),
                'attempts': row.get('attempts', '')
            })
    return progress

def create_user_activities_table(data):
    """Extrai dados de atividades dos dados sintéticos"""
    activities = []
    for row in data:
        if row.get('activity_id') and row.get('record_type') == 'user_activity':  # Dados de atividade
            activities.append({
                'activity_id': row.get('activity_id', ''),
                'user_id': row.get('user_id', ''),
                'item_id': row.get('item_id', ''),
                'activity_type': row.get('activity_type', ''),
                'activity_date': row.get('activity_date', ''),
                'time_spent_minutes': row.get('time_spent_minutes', ''),
                'completion_percentage': row.get('completion_percentage', ''),
                'success': row.get('success', '')
            })
    return activities

def create_daily_engagement_table(data):
    """Extrai dados de engajamento diário dos dados sintéticos"""
    engagement = []
    seen_dates = set()
    
    for row in data:
        # Se tem daily_active_users, é dado sintético de engajamento
        if row.get('daily_active_users') and row.get('date') not in seen_dates:
            engagement.append({
                'date': row.get('date', ''),
                'daily_active_users': row.get('daily_active_users', ''),
                'page_views': row.get('page_views', ''),
                'avg_session_duration_minutes': row.get('avg_session_duration_minutes', ''),
                'bounce_rate': row.get('bounce_rate', ''),
                'new_registrations': row.get('new_registrations', ''),
                'course_completions': row.get('course_completions', '')
            })
            seen_dates.add(row.get('date'))
    
    return engagement

def save_gold_table(s3_client, gold_bucket, table_name, data):
    if not data:
        return
    
    output = io.StringIO()
    fieldnames = data[0].keys()
    writer = csv.DictWriter(output, fieldnames=fieldnames)
    writer.writeheader()
    
    for row in data:
        writer.writerow(row)
    
    key = f"gold/{table_name}.csv"
    s3_client.put_object(
        Bucket=gold_bucket,
        Key=key,
        Body=output.getvalue(),
        ContentType='text/csv'
    )
    
    logger.info(f"Tabela salva: s3://{gold_bucket}/{key} ({len(data)} registros)")
