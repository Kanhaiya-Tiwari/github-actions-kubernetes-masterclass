#!/bin/bash
# Description: Production Backup Script for Kubernetes Resources and DB
set -e

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups/${BACKUP_DATE}"
NAMESPACE="skillpulse"
S3_BUCKET="s3://skillpulse-backups-815210276744"

echo "Starting backup for ${NAMESPACE}..."
mkdir -p "${BACKUP_DIR}"

# 1. Backup K8s Manifests
kubectl get all -n ${NAMESPACE} -o yaml > "${BACKUP_DIR}/resources.yaml"
kubectl get cm,secrets -n ${NAMESPACE} -o yaml > "${BACKUP_DIR}/config_secrets.yaml"

# 2. Database Dump (Assuming MySQL)
echo "Dumping database..."
DB_POD=$(kubectl get pods -n ${NAMESPACE} -l app=mysql -o jsonpath="{.items[0].metadata.name}")
kubectl exec -n ${NAMESPACE} "${DB_POD}" -- mysqldump -u root -p${MYSQL_ROOT_PASSWORD} --all-databases > "${BACKUP_DIR}/db_dump.sql"

# 3. Compress and Upload
tar -czf "${BACKUP_DIR}.tar.gz" -C "./backups" "${BACKUP_DATE}"
aws s3 cp "${BACKUP_DIR}.tar.gz" "${S3_BUCKET}/"

echo "Backup completed: ${BACKUP_DATE}.tar.gz uploaded to S3."
rm -rf "${BACKUP_DIR}" "${BACKUP_DIR}.tar.gz"
