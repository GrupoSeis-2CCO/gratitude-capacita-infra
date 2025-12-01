#!/bin/bash
# User-data para EC2 Backend (Privada)
# Apenas prepara o ambiente - CI/CD fará o deploy

exec > >(tee /var/log/user-data-backend.log)
exec 2>&1

echo "=== Iniciando configuração backend $(date) ==="

# Instalar dependências básicas
apt-get update -y
apt-get install -y mysql-server wget unzip awscli ca-certificates curl gnupg

# Instalar Docker
echo "=== Instalando Docker ==="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Adicionar ubuntu ao grupo docker
usermod -aG docker ubuntu

# Iniciar e habilitar Docker
systemctl start docker
systemctl enable docker

echo "=== Docker instalado com sucesso ==="

# Instalar Java 21 (ainda necessário para build, mas runtime será no container)
echo "=== Instalando Java 21 ==="
wget -q https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz
tar -xzf jdk-21_linux-x64_bin.tar.gz -C /opt/
ln -sf /opt/jdk-21.* /opt/jdk-21
echo 'export JAVA_HOME=/opt/jdk-21' >> /etc/profile.d/jdk.sh
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile.d/jdk.sh

# Configurar MySQL
echo "=== Configurando MySQL ==="

# Configurar MySQL para aceitar conexões externas (necessário para Docker)
sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

systemctl start mysql
systemctl enable mysql
sleep 5

# Configurar senha do root
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mysql_root_password}';"
mysql -e "FLUSH PRIVILEGES;"

# Criar database e usuário da aplicação
# IMPORTANTE: Usuário precisa aceitar conexões de qualquer host (%) para funcionar com Docker
mysql -u root -p'${mysql_root_password}' <<EOF
CREATE DATABASE IF NOT EXISTS capacita;
CREATE USER IF NOT EXISTS '${database_user}'@'%' IDENTIFIED BY '${database_password}';
GRANT ALL PRIVILEGES ON capacita.* TO '${database_user}'@'%';
FLUSH PRIVILEGES;
EOF

echo "=== Database capacita criado ==="
echo "=== Usuário ${database_user} criado com acesso de qualquer host ==="

# Reiniciar MySQL para aplicar bind-address
systemctl restart mysql
sleep 3

echo "=== MySQL configurado para aceitar conexões externas ==="

# Criar diretório da aplicação (agora /usr/share/api para o Docker)
mkdir -p /usr/share/api
chown -R ubuntu:ubuntu /usr/share/api

# Criar diretório para compose files
mkdir -p /home/ubuntu/api
chown -R ubuntu:ubuntu /home/ubuntu/api

# ========================================
# CONFIGURAÇÃO DO BACKUP AUTOMÁTICO
# ========================================
echo "=== Configurando backup automático do MySQL ==="

# Criar diretório de backups
mkdir -p /var/backups/mysql
chown ubuntu:ubuntu /var/backups/mysql

# Baixar script de backup do S3 ou criar localmente
cat > /usr/local/bin/backup_db.sh << 'BACKUP_SCRIPT'
#!/bin/bash
# Backup automatizado do banco MySQL capacita
# Envia para S3 e notifica por email via SNS

set -euo pipefail

# Configurações
DB_NAME="capacita"
DB_USER="root"
BACKUP_DIR="/var/backups/mysql"
DATE=\$(date +%Y-%m-%d)
TIMESTAMP=\$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="\$${DB_NAME}-backup-\$${DATE}.sql.gz"
BACKUP_PATH="\$${BACKUP_DIR}/\$${BACKUP_FILE}"

echo "[\$(date)] ===== INICIANDO BACKUP DO BANCO DE DADOS ====="

# Validar variáveis obrigatórias
if [ -z "\$${MYSQL_ROOT_PASSWORD:-}" ]; then
    echo "[ERRO] MYSQL_ROOT_PASSWORD não definida"
    exit 1
fi

if [ -z "\$${BACKUP_BUCKET_NAME:-}" ]; then
    echo "[ERRO] BACKUP_BUCKET_NAME não definida"
    exit 1
fi

# Criar diretório de backup se não existir
mkdir -p "\$${BACKUP_DIR}"

# 1. GERAR DUMP DO BANCO
echo "[\$(date)] Gerando dump do banco \$${DB_NAME}..."
if mysqldump -u "\$${DB_USER}" -p"\$${MYSQL_ROOT_PASSWORD}" \
    --single-transaction \
    --quick \
    --lock-tables=false \
    "\$${DB_NAME}" | gzip > "\$${BACKUP_PATH}"; then
    
    BACKUP_SIZE=\$(du -h "\$${BACKUP_PATH}" | cut -f1)
    echo "[\$(date)] ✅ Backup criado com sucesso: \$${BACKUP_FILE} (\$${BACKUP_SIZE})"
else
    echo "[\$(date)] ❌ ERRO ao criar backup do banco"
    
    # Notificar erro via SNS
    if [ -n "\$${SNS_TOPIC_ARN:-}" ]; then
        aws sns publish \
            --topic-arn "\$${SNS_TOPIC_ARN}" \
            --subject "❌ FALHA - Backup MySQL \$${DB_NAME} - \$${DATE}" \
            --message "Erro ao gerar dump do banco de dados capacita em \$${TIMESTAMP}. Verifique a instância EC2 urgentemente." \
            --region "\$${AWS_REGION:-us-east-1}" || true
    fi
    
    exit 1
fi

# 2. ENVIAR PARA S3
echo "[\$(date)] Enviando backup para S3..."
if aws s3 cp "\$${BACKUP_PATH}" "s3://\$${BACKUP_BUCKET_NAME}/\$${BACKUP_FILE}" \
    --region "\$${AWS_REGION:-us-east-1}"; then
    
    echo "[\$(date)] ✅ Backup enviado para s3://\$${BACKUP_BUCKET_NAME}/\$${BACKUP_FILE}"
    UPLOAD_SUCCESS=true
else
    echo "[\$(date)] ❌ ERRO ao enviar backup para S3"
    UPLOAD_SUCCESS=false
fi

# 3. ENVIAR EMAIL DE NOTIFICAÇÃO
if [ "\$${UPLOAD_SUCCESS}" = true ]; then
    # Sucesso
    MESSAGE="✅ BACKUP REALIZADO COM SUCESSO

Banco de dados: \$${DB_NAME}
Data/Hora: \$${TIMESTAMP}
Arquivo: \$${BACKUP_FILE}
Tamanho: \$${BACKUP_SIZE}
Localização: s3://\$${BACKUP_BUCKET_NAME}/\$${BACKUP_FILE}

O backup foi criado e enviado para o S3 com sucesso.
"
    
    if [ -n "\$${SNS_TOPIC_ARN:-}" ]; then
        aws sns publish \
            --topic-arn "\$${SNS_TOPIC_ARN}" \
            --subject "✅ Backup MySQL \$${DB_NAME} - \$${DATE}" \
            --message "\$${MESSAGE}" \
            --region "\$${AWS_REGION:-us-east-1}"
        
        echo "[\$(date)] ✅ Notificação de sucesso enviada"
    fi
    
    # Limpar backups locais mais antigos que 7 dias
    find "\$${BACKUP_DIR}" -name "*.sql.gz" -mtime +7 -delete
    echo "[\$(date)] Backups locais antigos removidos"
    
else
    # Falha no upload
    MESSAGE="❌ FALHA NO UPLOAD DO BACKUP

Banco de dados: \$${DB_NAME}
Data/Hora: \$${TIMESTAMP}
Arquivo: \$${BACKUP_FILE}
Tamanho: \$${BACKUP_SIZE}
Erro: Falha ao enviar para S3

O dump foi criado localmente em \$${BACKUP_PATH}, mas NÃO foi enviado para o S3.
Verifique as credenciais AWS e a conectividade da instância.
"
    
    if [ -n "\$${SNS_TOPIC_ARN:-}" ]; then
        aws sns publish \
            --topic-arn "\$${SNS_TOPIC_ARN}" \
            --subject "⚠️ FALHA PARCIAL - Backup MySQL \$${DB_NAME} - \$${DATE}" \
            --message "\$${MESSAGE}" \
            --region "\$${AWS_REGION:-us-east-1}" || true
    fi
    
    exit 1
fi

echo "[\$(date)] ===== BACKUP CONCLUÍDO COM SUCESSO ====="
exit 0
BACKUP_SCRIPT

chmod +x /usr/local/bin/backup_db.sh

# Criar arquivo de variáveis de ambiente para o script de backup
cat > /etc/environment.backup <<ENV_BACKUP
MYSQL_ROOT_PASSWORD=${mysql_root_password}
BACKUP_BUCKET_NAME=${backup_bucket_name}
SNS_TOPIC_ARN=${sns_topic_arn}
AWS_REGION=${aws_region}
ENV_BACKUP

# ========================================
# VARIÁVEIS DE AMBIENTE PARA A APLICAÇÃO
# ========================================
echo "=== Configurando variáveis de ambiente para a aplicação ==="

cat >> /etc/environment <<ENV_APP
# Email Configuration (Gmail SMTP)
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=${mail_username}
MAIL_PASSWORD=${mail_password}
ENV_APP

# Exportar também para a sessão atual
export MAIL_HOST=smtp.gmail.com
export MAIL_PORT=587
export MAIL_USERNAME="${mail_username}"
export MAIL_PASSWORD="${mail_password}"

echo "=== ✅ Variáveis de email configuradas ==="

# Configurar cron job para executar todos os dias às 02:00 AM
CRON_LOG="/var/log/backup_mysql_cron.log"
touch "$${CRON_LOG}"
chmod 644 "$${CRON_LOG}"

# Adicionar ao crontab do root (necessário para acesso ao MySQL)
(crontab -l 2>/dev/null | grep -v "/usr/local/bin/backup_db.sh" || true; echo "0 2 * * * . /etc/environment.backup && /usr/local/bin/backup_db.sh >> $${CRON_LOG} 2>&1") | crontab -

# Garantir que o serviço cron está rodando
systemctl enable cron 2>/dev/null || systemctl enable crond 2>/dev/null || true
systemctl start cron 2>/dev/null || systemctl start crond 2>/dev/null || true

echo "=== ✅ Backup automático configurado para executar diariamente às 02:00 AM ==="
echo "=== Script: /usr/local/bin/backup_db.sh ==="
echo "=== Log: $${CRON_LOG} ==="

echo "=== Ambiente backend pronto para CI/CD (Docker) ==="
echo "=== User-data concluído $(date) ==="
