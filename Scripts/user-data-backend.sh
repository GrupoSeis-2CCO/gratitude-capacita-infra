#!/bin/bash

# Redirecionar toda a saída para um log
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Iniciando user-data script $(date) ==="

# Instalar MySQL, Java 21, Maven, Git, OpenSSL e AWS CLI
echo "=== Instalando pacotes ==="
apt-get update -y
apt-get install -y mysql-server git maven wget unzip awscli openssl

# Instalar Java 21 manualmente (OpenJDK 21)
wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz
tar -xzf jdk-21_linux-x64_bin.tar.gz -C /opt/
ln -s /opt/jdk-21.* /opt/jdk-21
echo 'export JAVA_HOME=/opt/jdk-21' >> /etc/profile.d/jdk.sh
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile.d/jdk.sh
source /etc/profile.d/jdk.sh

# Configurar MySQL
systemctl start mysql
sleep 10

# Configurar senha do root
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mysql_root_password}';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Criar database e rodar schema
echo "=== Criando database capacita ==="
mysql -u root -p'${mysql_root_password}' -e "CREATE DATABASE IF NOT EXISTS capacita;"

echo "=== Baixando schema.sql ==="
wget -O /tmp/schema.sql https://raw.githubusercontent.com/GrupoSeis-2CCO/be-gratitude-capacita/main/Database/Script.sql

if [ ! -f /tmp/schema.sql ]; then
    echo "=== ERRO: schema.sql não foi baixado! ==="
    exit 1
fi

echo "=== Executando schema.sql ==="
mysql -u root -p'${mysql_root_password}' capacita < /tmp/schema.sql 2>&1 | tee /tmp/schema-output.log

SCHEMA_EXIT_CODE=$?
if [ $SCHEMA_EXIT_CODE -ne 0 ]; then
    echo "=== ERRO ao executar schema.sql: ==="
    cat /tmp/schema-output.log
    exit 1
else
    echo "=== schema.sql executado sem erros ==="
fi

echo "=== Verificando se as tabelas foram criadas ==="
mysql -u root -p'${mysql_root_password}' capacita -e "SHOW TABLES;"

# Baixar e executar data.sql (dados iniciais - inserts de usuario, cargo, etc)
echo "=== Baixando data.sql ==="
wget -O /tmp/data.sql https://raw.githubusercontent.com/GrupoSeis-2CCO/be-gratitude-capacita/main/src/main/resources/data.sql

if [ -f /tmp/data.sql ]; then
    echo "=== data.sql baixado com sucesso ==="
    
    echo "=== Executando data.sql no database capacita ==="
    mysql -u root -p'${mysql_root_password}' capacita < /tmp/data.sql
    
    if [ $? -eq 0 ]; then
        echo "=== data.sql executado com sucesso ==="
    else
        echo "=== ERRO ao executar data.sql ==="
    fi
    
    echo "=== Verificando dados inseridos ==="
    mysql -u root -p'${mysql_root_password}' capacita -e "SELECT COUNT(*) as total_cargos FROM cargo;"
    mysql -u root -p'${mysql_root_password}' capacita -e "SELECT COUNT(*) as total_usuarios FROM usuario;"
    mysql -u root -p'${mysql_root_password}' capacita -e "SELECT * FROM cargo;"
    mysql -u root -p'${mysql_root_password}' capacita -e "SELECT id, nome, email FROM usuario;"
else
    echo "=== ERRO: data.sql não foi baixado! ==="
fi

# Criar diretorio do app
mkdir -p /opt/app

# Gerar secret para JWT (runtime) — será expandido pelo shell no momento do provisionamento
JWT_SECRET=$(openssl rand -base64 32)
echo "Generated JWT secret (first 8 chars): $${JWT_SECRET:0:8}"

# Baixar JAR do GitHub
wget -O /opt/app/app.jar https://github.com/GrupoSeis-2CCO/be-gratitude-capacita/releases/download/NEW/be-gratitude-capacita-0.0.1-SNAPSHOT.jar
chmod +x /opt/app/app.jar

# Criar application.properties (com TODAS as propriedades que o Spring precisa)
cat > /opt/app/application.properties <<EOF
server.port=8081
spring.datasource.url=jdbc:mysql://localhost:3306/capacita
spring.datasource.username=root
spring.datasource.password=${mysql_root_password}
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false

# Configuracoes AWS S3 (nomes vindos do Terraform)
aws.s3.region=us-east-1
aws.s3.bucket.bronze=${bronze_bucket}
aws.s3.bucket.silver=${silver_bucket}
aws.s3.bucket.gold=${gold_bucket}
# JWT secret used by the application; generated at instance boot
jwt.secret=$JWT_SECRET
EOF

# Ajustar dono do diretório do app para o usuário que executará o serviço
chown -R ubuntu:ubuntu /opt/app

# Criar servico Spring Boot
cat > /etc/systemd/system/spring-app.service <<'EOF'
[Unit]
Description=Spring Boot Gratitude App
After=mysql.service

[Service]
User=ubuntu
WorkingDirectory=/opt/app
Environment="JAVA_HOME=/opt/jdk-21"
Environment="PATH=/opt/jdk-21/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/opt/jdk-21/bin/java -jar /opt/app/app.jar --spring.config.location=file:/opt/app/application.properties
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Instalar GitHub Actions Runner
cd /home/ubuntu
mkdir -p actions-runner && cd actions-runner
wget -O actions-runner-linux-x64.tar.gz https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64.tar.gz
chown -R ubuntu:ubuntu /home/ubuntu/actions-runner

# Clonar repositorio
cd /home/ubuntu
sudo -u ubuntu git clone https://github.com/GrupoSeis-2CCO/be-gratitude-capacita.git
chown -R ubuntu:ubuntu /home/ubuntu/be-gratitude-capacita

# Iniciar Spring Boot service
systemctl daemon-reload
systemctl enable spring-app.service
systemctl start spring-app.service

echo "Setup completo!"
