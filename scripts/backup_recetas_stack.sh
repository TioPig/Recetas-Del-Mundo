#!/usr/bin/env bash

set -euo pipefail

# Backup completo del stack de Recetas-Del-Mundo (Docker + DB)
# - Dumpea base de datos Postgres (pg_dump)
# - Respalda volúmenes nombrados (postgres_data, pgadmin_data)
# - Guarda imágenes Docker usadas por el stack
# - Copia docker-compose.yml y configs relevantes
# - Genera un tar.gz único con timestamp
# - Aplica retención de 7 días (borra respaldos más antiguos)

# Ubicaciones
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"
BACKUP_ROOT="$ROOT_DIR/backups"
TMP_DIR="$(mktemp -d -p "${BACKUP_ROOT:-/tmp}" backup_recetas_stack.XXXXXX)"

# Config por defecto (se puede sobreescribir vía .env o entorno)
POSTGRES_CONTAINER_NAME="${POSTGRES_CONTAINER_NAME:-api-recetas-postgres}"
PGADMIN_CONTAINER_NAME="${PGADMIN_CONTAINER_NAME:-api-recetas-pgadmin}"
BACKEND_IMAGE_NAME="${BACKEND_IMAGE_NAME:-api-recetas_final-backend:latest}"
POSTGRES_VOLUME="${POSTGRES_VOLUME:-postgres_data}"
PGADMIN_VOLUME="${PGADMIN_VOLUME:-pgadmin_data}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_STAGING="$TMP_DIR/staging"
mkdir -p "$BACKUP_ROOT" "$BACKUP_STAGING" "$BACKUP_STAGING/database" "$BACKUP_STAGING/volumes" "$BACKUP_STAGING/docker" "$BACKUP_STAGING/config" "$BACKUP_STAGING/artifacts"

echo "[INFO] Raíz repo: $ROOT_DIR"
echo "[INFO] Carpeta backups: $BACKUP_ROOT"
echo "[INFO] Timestamp: $TIMESTAMP"

# Cargar variables desde .env si existe (compat Windows CRLF)
ENV_FILE="$ROOT_DIR/.env"
if [[ -f "$ENV_FILE" ]]; then
  echo "[INFO] Cargando variables de $ENV_FILE"
  CLEAN_ENV="$(mktemp)"
  tr -d '\r' < "$ENV_FILE" > "$CLEAN_ENV"
  set -a
  # shellcheck disable=SC1090
  . "$CLEAN_ENV"
  set +a
  rm -f "$CLEAN_ENV"
fi

# Defaults según docker-compose.yml si no están en entorno
POSTGRES_DB="${POSTGRES_DB:-api_recetas_postgres}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"

COMPOSE_FILE="$ROOT_DIR/docker-compose.yml"
COMPOSE_CMD="docker compose"
if ! docker compose version >/dev/null 2>&1; then
  if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
  fi
fi

echo "[INFO] Usando comando compose: $COMPOSE_CMD"

# 1) Dump de la base de datos (pg_dump)
DB_DUMP_PATH="$BACKUP_STAGING/database/pgdump_${POSTGRES_DB}_${TIMESTAMP}.sql"
DB_DUMP_GZ="$DB_DUMP_PATH.gz"
echo "[INFO] Generando dump de Postgres desde contenedor $POSTGRES_CONTAINER_NAME (db=$POSTGRES_DB, user=$POSTGRES_USER)"
set +e
if [[ -z "$POSTGRES_PASSWORD" ]]; then
  echo "[WARN] POSTGRES_PASSWORD no definido. Intentando pg_dump sin PGPASSWORD (puede fallar)."
  docker exec "$POSTGRES_CONTAINER_NAME" sh -lc "pg_dump -U '$POSTGRES_USER' -d '$POSTGRES_DB'" > "$DB_DUMP_PATH"
else
  docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" "$POSTGRES_CONTAINER_NAME" sh -lc "pg_dump -U '$POSTGRES_USER' -d '$POSTGRES_DB'" > "$DB_DUMP_PATH"
fi
DB_DUMP_RC=$?
set -e
if [[ $DB_DUMP_RC -ne 0 ]]; then
  echo "[ERROR] Falló pg_dump (rc=$DB_DUMP_RC). Continuaré con volúmenes e imágenes, pero revisa credenciales/estado del contenedor."
  rm -f "$DB_DUMP_PATH"
else
  gzip -9 "$DB_DUMP_PATH"
  echo "[OK] Dump generado: $DB_DUMP_GZ"
fi

# 2) Backup de volúmenes nombrados (postgres_data, pgadmin_data)
echo "[INFO] Respaldo de volúmenes Docker"
if docker volume inspect "$POSTGRES_VOLUME" >/dev/null 2>&1; then
  docker run --rm -v "$POSTGRES_VOLUME:/volume" -v "$BACKUP_STAGING/volumes:/backup" alpine sh -c "tar -czf /backup/${POSTGRES_VOLUME}_${TIMESTAMP}.tar.gz -C /volume ."
  echo "[OK] Volumen $POSTGRES_VOLUME respaldado"
else
  echo "[WARN] Volumen $POSTGRES_VOLUME no existe"
fi

if docker volume inspect "$PGADMIN_VOLUME" >/dev/null 2>&1; then
  docker run --rm -v "$PGADMIN_VOLUME:/volume" -v "$BACKUP_STAGING/volumes:/backup" alpine sh -c "tar -czf /backup/${PGADMIN_VOLUME}_${TIMESTAMP}.tar.gz -C /volume ."
  echo "[OK] Volumen $PGADMIN_VOLUME respaldado"
else
  echo "[WARN] Volumen $PGADMIN_VOLUME no existe"
fi

# 3) Guardar imágenes Docker usadas por el stack
echo "[INFO] Guardando imágenes Docker del stack"
IMAGES_LIST=""
if [[ -f "$COMPOSE_FILE" ]]; then
  set +e
  IMAGES_LIST="$($COMPOSE_CMD -f "$COMPOSE_FILE" images --quiet 2>/dev/null | sort -u | tr '\n' ' ')"
  set -e
fi
# fallback a nombres conocidos
if [[ -z "$IMAGES_LIST" ]]; then
  IMAGES_LIST="postgres:15-alpine dpage/pgadmin4:8.11 $BACKEND_IMAGE_NAME"
fi
echo "[INFO] Imágenes a salvar: $IMAGES_LIST"
set +e
docker save -o "$BACKUP_STAGING/docker/images_${TIMESTAMP}.tar" $IMAGES_LIST
IMAGES_RC=$?
set -e
if [[ $IMAGES_RC -ne 0 ]]; then
  echo "[WARN] No se pudieron guardar todas las imágenes (rc=$IMAGES_RC). Continúo."
else
  echo "[OK] Imágenes guardadas en docker/images_${TIMESTAMP}.tar"
fi

# 4) Copiar compose y configs útiles
echo "[INFO] Copiando configuración relevante"
cp -f "$COMPOSE_FILE" "$BACKUP_STAGING/config/" 2>/dev/null || true
[[ -f "$ROOT_DIR/pgadmin/servers.json" ]] && cp -f "$ROOT_DIR/pgadmin/servers.json" "$BACKUP_STAGING/config/servers.json"
[[ -f "$ROOT_DIR/Springboot/Dockerfile" ]] && cp -f "$ROOT_DIR/Springboot/Dockerfile" "$BACKUP_STAGING/config/"
[[ -f "$ROOT_DIR/Springboot/pom.xml" ]] && cp -f "$ROOT_DIR/Springboot/pom.xml" "$BACKUP_STAGING/config/"
[[ -f "$ROOT_DIR/docker-compose.prod.yml" ]] && cp -f "$ROOT_DIR/docker-compose.prod.yml" "$BACKUP_STAGING/config/docker-compose.prod.yml"
# Opcional: incluir .env (contiene secretos). Si habilitas, descomenta la línea siguiente y protege tus backups.
# cp -f "$ROOT_DIR/.env" "$BACKUP_STAGING/config/.env"

# 4b) Artefactos (jar de Spring Boot)
echo "[INFO] Incluyendo artefactos de Spring Boot (si existen)"
JAR_DIR="$ROOT_DIR/Springboot/target"
if [[ -d "$JAR_DIR" ]]; then
  JAR_FILE="$(ls -1t "$JAR_DIR"/*.jar 2>/dev/null | grep -v '\.original$' | head -n1 || true)"
  if [[ -n "$JAR_FILE" && -f "$JAR_FILE" ]]; then
    cp -f "$JAR_FILE" "$BACKUP_STAGING/artifacts/"
    (cd "$BACKUP_STAGING/artifacts" && sha256sum "$(basename "$JAR_FILE")" > SHA256SUMS.txt ) || true
    echo "[OK] Artefacto incluido: $(basename "$JAR_FILE")"
  else
    echo "[WARN] No se encontró .jar en $JAR_DIR"
  fi
else
  echo "[WARN] Carpeta $JAR_DIR no existe"
fi

# 5) Generar tar.gz final
FINAL_TAR="$BACKUP_ROOT/complete_backup_${TIMESTAMP}.tar.gz"
echo "[INFO] Empaquetando backup: $FINAL_TAR"
tar -C "$BACKUP_STAGING" -czf "$FINAL_TAR" .
echo "[OK] Backup completado: $FINAL_TAR"

# 6) Retención por días (borra > N días)
echo "[INFO] Aplicando retención de ${RETENTION_DAYS} días en $BACKUP_ROOT"
set +e
find "$BACKUP_ROOT" -type f -name 'complete_backup_*.tar.gz' -mtime +"$RETENTION_DAYS" -print -delete
set -e

# Limpieza temporal
rm -rf "$TMP_DIR"
echo "[DONE] Respaldo finalizado"

# Sugerencia de crontab (ejecutar diario a las 02:30)
# 30 2 * * * /bin/bash /ruta/al/repo/scripts/backup_recetas_stack.sh >> /var/log/backup_recetas.log 2>&1
