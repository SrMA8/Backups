#!/bin/bash

set -e

source .env

DATE=$(date +%Y-%m-%d_%H-%M-%S)

mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/backup_$DATE.log"

echo "[$DATE] Iniciando respaldo..." >> "$LOG_FILE"

mysql -u $DB_USER -p$DB_PASSWORD -e "USE $DB_NAME;" 2>> "$LOG_FILE"

mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > "$BACKUP_DIR/$DB_NAME-$DATE.sql" 2>> "$LOG_FILE"

gzip "$BACKUP_DIR/$DB_NAME-$DATE.sql"

gpg -c "$BACKUP_DIR/$DB_NAME-$DATE.sql.gz"

scp "$BACKUP_DIR/$DB_NAME-$DATE.sql.gz.gpg" $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR

find "$BACKUP_DIR" -type f -name "*.gpg" -mtime +7 -exec rm {} \;

echo "[$DATE] Respaldo completado correctamente" >> "$LOG_FILE"