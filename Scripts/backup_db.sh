#!/bin/bash
# Backup do banco MySQL (capacita) e envio para S3
# Uso previsto: este script será instalado nas instâncias EC2 e executado via cron
# Variáveis esperadas no ambiente:
#  - MYSQL_ROOT_PASSWORD : senha root do MySQL
#  - BACKUP_BUCKET       : nome do bucket S3 onde o backup será enviado
#  - ADMIN_EMAIL         : email do administrador (para notificações)

set -euo pipefail

DB_NAME="${DB_NAME:-capacita}"

DATE=$(date -I)
OUT_FILE="${DB_NAME}-backup-${DATE}.sql.gz"

echo "[backup_db] Inicio do backup: ${DATE}"

if [ -z "${MYSQL_ROOT_PASSWORD:-}" ]; then
  echo "[backup_db] ERRO: MYSQL_ROOT_PASSWORD não definido"
  exit 1
fi

if [ -z "${BACKUP_BUCKET:-}" ]; then
  echo "[backup_db] ERRO: BACKUP_BUCKET não definido"
  exit 1
fi

TMP_PATH="/tmp/${OUT_FILE}"

echo "[backup_db] Gerando dump do banco..."
mysqldump -u root -p"${MYSQL_ROOT_PASSWORD}" "${DB_NAME}" | gzip > "${TMP_PATH}"

if [ $? -ne 0 ] || [ ! -s "${TMP_PATH}" ]; then
  echo "[backup_db] ERRO: mysqldump falhou ou arquivo vazio"
  # tentativa de notificar via SES (se configurado)
  if command -v aws >/dev/null 2>&1; then
    if [ -n "${ADMIN_EMAIL:-}" ]; then
      aws ses send-email --from "${ADMIN_EMAIL}" --destination "ToAddresses=${ADMIN_EMAIL}" --message "Subject={Data=CAPACITA Backup FALHOU ${DATE}},Body={Text={Data=Erro ao gerar backup do banco capacita em ${DATE}}}" || true
    fi
  fi
  exit 1
fi

echo "[backup_db] Enviando para s3://${BACKUP_BUCKET}/${OUT_FILE}"
if command -v aws >/dev/null 2>&1; then
  aws s3 cp "${TMP_PATH}" "s3://${BACKUP_BUCKET}/${OUT_FILE}" --only-show-errors
  BODY="Erro ao gerar backup do banco ${DB_NAME} em ${DATE}"
else
  echo "[backup_db] ERRO: AWS CLI não encontrado"
  UPLOAD_EXIT=2
fi

if [ ${UPLOAD_EXIT} -ne 0 ]; then
  echo "[backup_db] ERRO: falha no upload para S3 (code ${UPLOAD_EXIT})"
  # Tentar notificar via MTA local (mail/sendmail). Se não existir, logar em /var/log/backup_notifications.log
  if [ -n "${ADMIN_EMAIL:-}" ]; then
    SUBJECT="CAPACITA Backup UPLOAD FALHOU ${DATE}"
    BODY="Erro ao enviar backup para S3 do banco ${DB_NAME}. Exit code: ${UPLOAD_EXIT}"
    if command -v mail >/dev/null 2>&1; then
      echo "${BODY}" | mail -s "${SUBJECT}" "${ADMIN_EMAIL}" || true
    elif command -v sendmail >/dev/null 2>&1; then
      printf "Subject: %s\n\n%s" "${SUBJECT}" "${BODY}" | sendmail "${ADMIN_EMAIL}" || true
    else
      echo "$(date) ${SUBJECT} - ${BODY}" >> /var/log/backup_notifications.log
    fi
  fi
  exit 1
fi

echo "[backup_db] Upload concluido com sucesso"

if [ -n "${ADMIN_EMAIL:-}" ]; then
  SUBJECT="CAPACITA Backup OK ${DATE}"
  BODY="Backup do banco ${DB_NAME} criado e enviado para s3://${BACKUP_BUCKET}/${OUT_FILE}"
  if command -v mail >/dev/null 2>&1; then
    echo "${BODY}" | mail -s "${SUBJECT}" "${ADMIN_EMAIL}" || true
  elif command -v sendmail >/dev/null 2>&1; then
    printf "Subject: %s\n\n%s" "${SUBJECT}" "${BODY}" | sendmail "${ADMIN_EMAIL}" || true
  else
    echo "$(date) ${SUBJECT} - ${BODY}" >> /var/log/backup_notifications.log
  fi
fi

# remover arquivo local
rm -f "${TMP_PATH}"

echo "[backup_db] Finalizado"

exit 0
