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
BACKUP_PATH="./backups/$FILE_NAME"
COMPRESSED_PATH="$BACKUP_PATH.7z"

echo "$PREFIX INFO: starting backup to $FILE_NAME" >> ./logs.txt

if [[ "$DATABASE_TYPE" == "mysql" ]]; then
  DUMP_CMD="mysqldump --all-databases"
else
  DUMP_CMD="pg_dumpall"
fi

if ssh "$USER@$REMOTE" "$DUMP_CMD" > "$BACKUP_PATH"; then
  echo "$PREFIX SUCCESS: backup created for $FILE_NAME" >> ./logs.txt

  SEVEN_ZIP="/c/Program Files/7-Zip/7z.exe"

  if "$SEVEN_ZIP" a -t7z "$COMPRESSED_PATH" "$BACKUP_PATH"; then
    echo "$PREFIX SUCCESS: compressed $FILE_NAME to $(basename "$COMPRESSED_PATH")" >> ./logs.txt

    rm "$BACKUP_PATH"
    echo "$PREFIX INFO: deleted uncompressed file $FILE_NAME" >> ./logs.txt
  else
    echo "$PREFIX ERROR: compression failed for $FILE_NAME" >> ./logs.txt
  fi
else
  echo "$PREFIX ERROR: backup failed for $FILE_NAME" >> ./logs.txt
fi
