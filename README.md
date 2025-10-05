# Gratitude Capacita - Infraestrutura AWS

Infraestrutura como código (Terraform) para o projeto Gratitude Capacita.

## 📋 Pré-requisitos

- [Terraform](https://www.terraform.io/downloads) instalado
- Conta AWS Academy (ou AWS regular)
- Git instalado
- SSH client (já incluído no Windows 10+)

## 🚀 Configuração Inicial

### 1️⃣ Baixar a Chave SSH do AWS Academy

No AWS Academy Lab, clique em **"SSH key"** e depois em **"Download PEM"**:

![AWS Academy SSH Key Download](https://docs.aws.amazon.com/awsacademy/latest/lab-foundation/images/ssh-key-download.png)

**⚠️ IMPORTANTE:** Renomeie o arquivo baixado para `vockey.pem` e coloque na pasta `keys/`:

```powershell
# Criar a pasta keys se não existir
mkdir keys

# Mover e renomear o arquivo (ajuste o caminho do arquivo baixado)
move ~\Downloads\labsuser.pem keys\vockey.pem
```

### 2️⃣ Configurar Variáveis Sensíveis

Crie o arquivo `Scripts/terraform.tfvars` com suas credenciais:

```powershell
# Copiar o template
cd Scripts
copy terraform.tfvars.example terraform.tfvars
```

Edite o arquivo `Scripts/terraform.tfvars` e defina sua senha do MySQL:

```hcl
mysql_root_password = "sua_senha_mysql_segura"
```

**⚠️ ATENÇÃO:** 
- Este arquivo **NÃO** deve ser commitado no Git (já está no `.gitignore`)
- Use uma senha forte e segura
- A senha pode conter caracteres especiais (#, @, !, etc)

### 3️⃣ Inicializar e Aplicar o Terraform

```powershell
cd Scripts

# Inicializar Terraform (baixa providers)
terraform init

# Visualizar o que será criado
terraform plan

# Criar a infraestrutura
terraform apply
```

Digite `yes` quando solicitado para confirmar a criação dos recursos.

## 🏗️ Recursos Criados

A infraestrutura cria:

- **VPC** com subnets públicas e privadas
- **NAT Gateway** para acesso à internet das instâncias privadas
- **EC2 Bastion** (instância pública para acesso SSH)
- **EC2 Backend** (instância privada com Spring Boot + MySQL)
- **Load Balancer** (Application Load Balancer)
- **S3 Buckets** (bronze, silver, gold para data lake)
- **Security Groups** configurados

## 🔐 Acessar as Instâncias

### Acessar o Bastion (instância pública):

```powershell
# Obter o IP público do bastion
cd Scripts
terraform output bastion_public_ip

# Conectar via SSH
ssh -i "..\keys\vockey.pem" ubuntu@<IP_DO_BASTION>
```

### Acessar o Backend (instância privada via bastion):

```powershell
# Dentro do bastion, conectar ao backend
ssh ubuntu@10.0.2.X  # O IP privado é mostrado no terraform output
```

Ou diretamente do seu computador usando proxy jump:

```powershell
ssh -i "keys\vockey.pem" -J ubuntu@<IP_BASTION> ubuntu@10.0.2.X
```

## 🧪 Validar a Aplicação Backend

Conecte na instância backend e execute:

```bash
# Verificar se cloud-init terminou
sudo cloud-init status

# Verificar MySQL
sudo systemctl status mysql
mysql -u root -p'sua_senha' capacita -e "SHOW TABLES;"

# Verificar Spring Boot
sudo systemctl status spring-app.service
sudo ss -tulpn | grep 8081

# Testar endpoint de login
curl -X POST http://localhost:8081/usuarios/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@doe.com","senha":"123456"}'

# Ver usuários no banco
mysql -u root -p'sua_senha' capacita -e "SELECT nome, email FROM usuario;"
```

## 🌐 Acessar a API do seu computador (Insomnia/Postman)

Para acessar a API que está rodando na instância privada, crie um túnel SSH:

```powershell
# Obter IPs
cd Scripts
terraform output

# Criar túnel SSH (substitua os IPs)
ssh -i "keys\vockey.pem" -L 8081:10.0.2.X:8081 ubuntu@<IP_BASTION> -N
```

Deixe esse terminal aberto e acesse no Insomnia/Postman:

```
POST http://localhost:8081/usuarios/login
Content-Type: application/json

{
  "email": "john@doe.com",
  "senha": "123456"
}
```

## 🔄 Recriar a Infraestrutura

Para recriar uma instância específica (ex: após atualizar user-data):

```powershell
cd Scripts
terraform apply -replace="aws_instance.ec2_privada_gratitude_backend"
```

Para destruir tudo:

```powershell
cd Scripts
terraform destroy
```

## 📁 Estrutura do Projeto

```
gratitude-capacita-infra/
├── keys/
│   └── vockey.pem              # Chave SSH (NÃO commitada)
├── Scripts/
│   ├── ec2.tf                  # Configuração das instâncias EC2
│   ├── vpc.tf                  # Configuração da VPC
│   ├── s3.tf                   # Buckets S3
│   ├── variaveis.tf            # Definição de variáveis
│   ├── terraform.tfvars        # Valores sensíveis (NÃO commitado)
│   ├── terraform.tfvars.example # Template para terraform.tfvars
│   └── user-data-backend.sh    # Script de inicialização do backend
├── SECURITY.md                 # Documentação de segurança
└── README.md                   # Este arquivo
```

## 🆘 Troubleshooting

### Erro: "Permission denied (publickey)"
- Verifique se a chave está nomeada `vockey.pem` na pasta `keys/`
- Verifique permissões: `icacls keys\vockey.pem /inheritance:r /grant:r "%USERNAME%:R"`

### Erro: "Could not resolve placeholder 'mysql_root_password'"
- Certifique-se de que criou o arquivo `Scripts/terraform.tfvars`
- Verifique se a variável está definida: `mysql_root_password = "sua_senha"`

### Spring Boot não inicia
- Conecte na instância e veja os logs: `sudo journalctl -u spring-app.service -n 100`
- Verifique se o MySQL está rodando: `sudo systemctl status mysql`

### Tabelas não foram criadas
- Verifique se o cloud-init terminou: `sudo cloud-init status`
- Veja os logs: `sudo cat /var/log/cloud-init-output.log`

## 👥 Equipe

Grupo 6 - Projeto Gratitude Capacita

## 📄 Licença

Este projeto é parte do curso e segue as diretrizes acadêmicas da instituição.