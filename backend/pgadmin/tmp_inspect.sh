#!/bin/sh
set -e
apk add --no-cache sqlite >/dev/null
echo "Tables:"
sqlite3 /var/lib/pgadmin/pgadmin4.db "SELECT name FROM sqlite_master WHERE type='table';"
echo "--- pragma table_info(server) ---"
sqlite3 /var/lib/pgadmin/pgadmin4.db "PRAGMA table_info('server');"
echo "--- sample rows ---"
sqlite3 /var/lib/pgadmin/pgadmin4.db "SELECT id, name, host, port, username, save_password, password, ssl_mode, comment FROM server LIMIT 10;"
