#!/bin/bash
source "$(dirname "$0")/.env"

PREFIX="$(date +'%Y-%m-%d %H:%M:%S') -"

if [[ "$DATABASE_TYPE" != "mysql" && "$DATABASE_TYPE" != "postgres" ]]; then
  echo "$PREFIX ERROR: DATABASE_TYPE in .env must be 'mysql' or 'postgres'" >> ./logs.txt
  exit 1
fi

mkdir -p ./backups
touch ./logs.txt

FILE_NAME="backup_$(date +'%Y-%m-%d_%H-%M-%S').sql"

echo "$PREFIX INFO: starting backup to $FILE_NAME" >> ./logs.txt

if [[ "$DATABASE_TYPE" == "mysql" ]]; then
  DUMP_CMD="mysqldump --all-databases"
else
  DUMP_CMD="pg_dumpall"
fi

if ssh "$USER@$REMOTE" "$DUMP_CMD" > "./backups/$FILE_NAME"; then
  echo "$PREFIX SUCCESS: backup created for $FILE_NAME" >> ./logs.txt
else
  echo "$PREFIX ERROR: backup failed for $FILE_NAME" >> ./logs.txt
fi