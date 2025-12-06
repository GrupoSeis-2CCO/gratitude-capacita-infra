# 🚀 Pipeline de Dados - Guia de Execução

## Pré-requisitos
- AWS Academy Lab iniciado
- Credenciais AWS configuradas no terminal

---

## 📋 Passo a Passo Completo

### 1️⃣ Upload dos CSVs para Bronze
```powershell
cd "C:\Users\nirsl\OneDrive\Documentos\Faculdade\Projeto Gratitude\gratitude-capacita-infra\Dados"

# Upload de todos os CSVs
Get-ChildItem *.csv | ForEach-Object { 
    Write-Host "Uploading: $($_.Name)" -ForegroundColor Yellow
    aws s3 cp $_.Name s3://gratitude-capacita-bronze-nov26/bronze/
}
```

### 2️⃣ Executar Lambda Bronze → Silver
```powershell
cd "C:\Users\nirsl\OneDrive\Documentos\Faculdade\Projeto Gratitude\gratitude-capacita-infra\Scripts"

# Executar Lambda
aws lambda invoke `
  --function-name projeto-pi-dados-bronze-to-silver-dev `
  --payload fileb://"C:\Users\nirsl\OneDrive\Documentos\Faculdade\Projeto Gratitude\gratitude-capacita-infra\Dados\payload_bronze.json" `
  response.json

# Ver resposta
Get-Content response.json
```

### 3️⃣ Aguardar e Verificar ONE BIG TABLE
```powershell
# Aguardar processamento (2 minutos)
Start-Sleep -Seconds 120

# Verificar arquivo criado
aws s3 ls s3://gratitude-capacita-silver-nov26/ --human-readable
```

### 4️⃣ Executar Lambda Silver → Gold
```powershell
# Executar Lambda
aws lambda invoke `
  --function-name projeto-pi-dados-silver-to-gold-dev `
  --payload fileb://"C:\Users\nirsl\OneDrive\Documentos\Faculdade\Projeto Gratitude\gratitude-capacita-infra\Dados\payload_silver.json" `
  response_gold.json

# Ver resposta
Get-Content response_gold.json
```

### 5️⃣ Aguardar e Verificar Tabelas Gold
```powershell
# Aguardar processamento (90 segundos)
Start-Sleep -Seconds 90

# Verificar todas as tabelas criadas
aws s3 ls s3://gratitude-capacita-gold-nov26/ --recursive --human-readable
```

---

## 🧹 Limpeza (se precisar reprocessar)

### Limpar apenas Silver e Gold (mantém Bronze)
```powershell
# Limpar Silver
aws s3 rm s3://gratitude-capacita-silver-nov26/ --recursive

# Limpar Gold
aws s3 rm s3://gratitude-capacita-gold-nov26/ --recursive
```

### Limpar tudo e começar do zero
```powershell
# Limpar Bronze
aws s3 rm s3://gratitude-capacita-bronze-nov26/bronze/ --recursive

# Limpar Silver
aws s3 rm s3://gratitude-capacita-silver-nov26/ --recursive

# Limpar Gold
aws s3 rm s3://gratitude-capacita-gold-nov26/ --recursive
```

---

## ⚡ Comando Único (Pipeline Completo)

```powershell
# Ir para pasta de dados
cd "C:\Users\nirsl\OneDrive\Documentos\Faculdade\Projeto Gratitude\gratitude-capacita-infra\Dados"

# 1. Upload CSVs
Write-Host "`n📤 1. Uploading CSVs..." -ForegroundColor Cyan
Get-ChildItem *.csv | ForEach-Object { aws s3 cp $_.Name s3://gratitude-capacita-bronze-nov26/bronze/ --quiet }

# 2. Lambda Bronze→Silver
Write-Host "`n⚙️  2. Processando Bronze → Silver..." -ForegroundColor Cyan
cd "..\Scripts"
aws lambda invoke --function-name projeto-pi-dados-bronze-to-silver-dev --payload fileb://"C:\Users\nirsl\OneDrive\Documentos\Faculdade\Projeto Gratitude\gratitude-capacita-infra\Dados\payload_bronze.json" response.json --no-cli-pager
Get-Content response.json

# 3. Aguardar
Write-Host "`n⏳ 3. Aguardando 120s..." -ForegroundColor Yellow
Start-Sleep -Seconds 120

# 4. Verificar Silver
Write-Host "`n✅ 4. Verificando ONE BIG TABLE..." -ForegroundColor Green
aws s3 ls s3://gratitude-capacita-silver-nov26/ --human-readable

# 5. Lambda Silver→Gold
Write-Host "`n⚙️  5. Processando Silver → Gold..." -ForegroundColor Cyan
aws lambda invoke --function-name projeto-pi-dados-silver-to-gold-dev --payload fileb://"C:\Users\nirsl\OneDrive\Documentos\Faculdade\Projeto Gratitude\gratitude-capacita-infra\Dados\payload_silver.json" response_gold.json --no-cli-pager
Get-Content response_gold.json

# 6. Aguardar
Write-Host "`n⏳ 6. Aguardando 90s..." -ForegroundColor Yellow
Start-Sleep -Seconds 90

# 7. Verificar Gold
Write-Host "`n✅ 7. Verificando tabelas Gold..." -ForegroundColor Green
aws s3 ls s3://gratitude-capacita-gold-nov26/ --recursive --human-readable

Write-Host "`n🎉 Pipeline completo!" -ForegroundColor Green
```

---

## 📊 Arquivos Esperados

### Silver Bucket
- `one_big_table.csv` - Tabela consolidada com todos os dados

### Gold Bucket
- `users.csv`
- `items.csv`
- `kpis.csv`
- `user_sessions.csv`
- `ratings.csv`
- `course_progress.csv`
- `user_activities.csv`
- `daily_engagement.csv`

---

## 🔍 Troubleshooting

### Se Lambda falhar
```powershell
# Ver logs da Lambda
aws logs tail /aws/lambda/projeto-pi-dados-bronze-to-silver-dev --since 10m

# Verificar status da função
aws lambda get-function --function-name projeto-pi-dados-bronze-to-silver-dev
```

### Se arquivos não aparecerem
```powershell
# Listar tudo no bucket (sem filtro de pasta)
aws s3 ls s3://gratitude-capacita-silver-nov26/ --recursive

# Ver detalhes do arquivo
aws s3 ls s3://gratitude-capacita-silver-nov26/one_big_table.csv --human-readable
```

### Se precisar reprocessar apenas Gold
```powershell
# Limpar apenas Gold
aws s3 rm s3://gratitude-capacita-gold-nov26/ --recursive

# Executar apenas Lambda Silver→Gold
aws lambda invoke --function-name projeto-pi-dados-silver-to-gold-dev --payload fileb://"C:\Users\nirsl\OneDrive\Documentos\Faculdade\Projeto Gratitude\gratitude-capacita-infra\Dados\payload_silver.json" response_gold.json
```
