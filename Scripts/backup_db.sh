#!/bin/bash
# Backup automatizado do banco MySQL capacita
# Envia para S3 e notifica por email via SNS

set -euo pipefail

# Configurações
DB_NAME="capacita"
DB_USER="root"
BACKUP_DIR="/var/backups/mysql"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="${DB_NAME}-backup-${DATE}.sql.gz"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_FILE}"

# Variáveis de ambiente esperadas (definidas no user-data)
# MYSQL_ROOT_PASSWORD
# BACKUP_BUCKET_NAME
# SNS_TOPIC_ARN
# AWS_REGION

echo "[$(date)] ===== INICIANDO BACKUP DO BANCO DE DADOS ====="

# Validar variáveis obrigatórias
if [ -z "${MYSQL_ROOT_PASSWORD:-}" ]; then
    echo "[ERRO] MYSQL_ROOT_PASSWORD não definida"
    exit 1
fi

if [ -z "${BACKUP_BUCKET_NAME:-}" ]; then
    echo "[ERRO] BACKUP_BUCKET_NAME não definida"
    exit 1
fi

# Criar diretório de backup se não existir
mkdir -p "${BACKUP_DIR}"

# 1. GERAR DUMP DO BANCO
echo "[$(date)] Gerando dump do banco ${DB_NAME}..."
if mysqldump -u "${DB_USER}" -p"${MYSQL_ROOT_PASSWORD}" \
    --single-transaction \
    --quick \
    --lock-tables=false \
    "${DB_NAME}" | gzip > "${BACKUP_PATH}"; then
    
    BACKUP_SIZE=$(du -h "${BACKUP_PATH}" | cut -f1)
    echo "[$(date)] ✅ Backup criado com sucesso: ${BACKUP_FILE} (${BACKUP_SIZE})"
else
    echo "[$(date)] ❌ ERRO ao criar backup do banco"
    
    # Notificar erro via SNS
    if [ -n "${SNS_TOPIC_ARN:-}" ]; then
        aws sns publish \
            --topic-arn "${SNS_TOPIC_ARN}" \
            --subject "❌ FALHA - Backup MySQL ${DB_NAME} - ${DATE}" \
            --message "Erro ao gerar dump do banco de dados capacita em ${TIMESTAMP}. Verifique a instância EC2 urgentemente." \
            --region "${AWS_REGION:-us-east-1}" || true
    fi
    
    exit 1
fi

# 2. ENVIAR PARA S3
echo "[$(date)] Enviando backup para S3..."
if aws s3 cp "${BACKUP_PATH}" "s3://${BACKUP_BUCKET_NAME}/${BACKUP_FILE}" \
    --region "${AWS_REGION:-us-east-1}"; then
    
    echo "[$(date)] ✅ Backup enviado para s3://${BACKUP_BUCKET_NAME}/${BACKUP_FILE}"
    UPLOAD_SUCCESS=true
else
    echo "[$(date)] ❌ ERRO ao enviar backup para S3"
    UPLOAD_SUCCESS=false
fi

# 3. ENVIAR EMAIL DE NOTIFICAÇÃO
if [ "${UPLOAD_SUCCESS}" = true ]; then
    # Sucesso
    MESSAGE="✅ BACKUP REALIZADO COM SUCESSO

Banco de dados: ${DB_NAME}
Data/Hora: ${TIMESTAMP}
Arquivo: ${BACKUP_FILE}
Tamanho: ${BACKUP_SIZE}
Localização: s3://${BACKUP_BUCKET_NAME}/${BACKUP_FILE}

O backup foi criado e enviado para o S3 com sucesso.
"
    
    if [ -n "${SNS_TOPIC_ARN:-}" ]; then
        aws sns publish \
            --topic-arn "${SNS_TOPIC_ARN}" \
            --subject "✅ Backup MySQL ${DB_NAME} - ${DATE}" \
            --message "${MESSAGE}" \
            --region "${AWS_REGION:-us-east-1}"
        
        echo "[$(date)] ✅ Notificação de sucesso enviada"
    fi
    
    # Limpar backups locais mais antigos que 7 dias
    find "${BACKUP_DIR}" -name "*.sql.gz" -mtime +7 -delete
    echo "[$(date)] Backups locais antigos removidos"
    
else
    # Falha no upload
    MESSAGE="❌ FALHA NO UPLOAD DO BACKUP

Banco de dados: ${DB_NAME}
Data/Hora: ${TIMESTAMP}
Arquivo: ${BACKUP_FILE}
Tamanho: ${BACKUP_SIZE}
Erro: Falha ao enviar para S3

O dump foi criado localmente em ${BACKUP_PATH}, mas NÃO foi enviado para o S3.
Verifique as credenciais AWS e a conectividade da instância.
"
    
    if [ -n "${SNS_TOPIC_ARN:-}" ]; then
        aws sns publish \
            --topic-arn "${SNS_TOPIC_ARN}" \
            --subject "⚠️ FALHA PARCIAL - Backup MySQL ${DB_NAME} - ${DATE}" \
            --message "${MESSAGE}" \
            --region "${AWS_REGION:-us-east-1}" || true
    fi
    
    exit 1
fi

echo "[$(date)] ===== BACKUP CONCLUÍDO COM SUCESSO ====="
exit 0