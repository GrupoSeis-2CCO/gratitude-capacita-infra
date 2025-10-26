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

echo "=== Ambiente backend pronto para CI/CD (Docker) ==="
echo "=== User-data concluído $(date) ==="
