#!/bin/sh
set -e
apk add --no-cache sqlite >/dev/null
echo "Users:"
sqlite3 /var/lib/pgadmin/pgadmin4.db "SELECT id || '|' || email || '|' || username FROM \"user\";"
