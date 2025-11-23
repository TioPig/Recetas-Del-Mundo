#!/usr/bin/env bash
set -euo pipefail

# Rotate backups: delete files older than N days in backup directory
# Usage: ./scripts/backup_rotate.sh [BACKUP_DIR] [DAYS]

BACKUP_DIR=${1:-/home/admin/api-recetas/backups}
KEEP_DAYS=${2:-14}

if [ ! -d "$BACKUP_DIR" ]; then
  echo "Backup dir does not exist: $BACKUP_DIR" >&2
  exit 1
fi

echo "Removing files older than $KEEP_DAYS days in $BACKUP_DIR"
find "$BACKUP_DIR" -maxdepth 1 -type f -mtime +$KEEP_DAYS -print -exec rm -f {} \;
echo "Removal complete"

exit 0
