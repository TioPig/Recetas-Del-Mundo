#!/bin/sh
set -e
apk add --no-cache sqlite >/dev/null
SQL="INSERT INTO server (user_id, servergroup_id, name, host, port, maintenance_db, username, password, comment, save_password) VALUES (1,1,'API Recetas PostgreSQL','postgres',5432,'api_recetas_postgres','postgres','kz!M8LYC6x&vFTy','Base principal',1);"
echo "Ejecutando SQL de inserción..."
sqlite3 /var/lib/pgadmin/pgadmin4.db "$SQL"
echo "Inserción completada. Server rows:"
sqlite3 /var/lib/pgadmin/pgadmin4.db "SELECT id, user_id, servergroup_id, name, host, port, username, save_password FROM server;"
