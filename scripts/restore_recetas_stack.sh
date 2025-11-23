#!/usr/bin/env bash

# Re-ejecutar con bash si fue invocado con sh (que no soporta 'pipefail')
if [ -z "${BASH_VERSION:-}" ]; then
  exec /usr/bin/env bash "$0" "$@"
fi

set -euo pipefail

# Restauración de backup generado por backup_recetas_stack.sh/.ps1
# Este script restaura:
#  - Imágenes Docker (docker load)
#  - Volúmenes Docker (desempaquetando cada tar.gz en el volumen)
#  - Dump de base de datos Postgres (opcional, si no restauraste el volumen o si deseas reimportar)
#
# Requisitos previos en el servidor Debian con Docker:
#  - Docker instalado y en ejecución
#  - Contenedores detenidos antes de restaurar volúmenes (docker compose down)
#  - Espacio suficiente en disco
#
# Uso:
#  restore_recetas_stack.sh /ruta/al/complete_backup_YYYYMMDD_HHMMSS.tar.gz [opciones]
#    Variables de entorno opcionales:
#      POSTGRES_CONTAINER_NAME (default: api-recetas-postgres)
#      POSTGRES_DB (default: api_recetas_postgres)
#      POSTGRES_USER (default: postgres)
#      RESTORE_DB (default: auto) -> auto|yes|no
#      COMPOSE_UP (default: no)   -> yes|no (si hay compose extraído)
#      ENV_FILE (default: auto)   -> ruta a .env para usar con compose (auto: usa $BASE_DIR/.env si existe)
#      BASE_DIR (default: /home/admin/api-recetas) -> directorio de trabajo en el servidor
#      DEPLOY_DIR (default: $BASE_DIR)            -> destino donde se dejará el compose antes de levantar

BASE_DIR="${BASE_DIR:-/home/admin/api-recetas}"
DEPLOY_DIR="${DEPLOY_DIR:-$BASE_DIR}"

BACKUP_TAR="${1:-}"
if [[ -z "$BACKUP_TAR" ]]; then
  # Intentar auto-descubrir el backup más reciente en $BASE_DIR/backups
  if [[ -d "$BASE_DIR/backups" ]]; then
    BACKUP_TAR="$(ls -1t "$BASE_DIR"/backups/complete_backup_*.tar.gz 2>/dev/null | head -n1 || true)"
  fi
  if [[ -z "$BACKUP_TAR" ]]; then
    echo "Uso: $0 /ruta/a/complete_backup_YYYYMMDD_HHMMSS.tar.gz" >&2
    echo "También puedes colocarlo en $BASE_DIR/backups y el script intentará detectarlo automáticamente." >&2
    exit 1
  fi
fi

POSTGRES_CONTAINER_NAME="${POSTGRES_CONTAINER_NAME:-api-recetas-postgres}"
POSTGRES_DB="${POSTGRES_DB:-api_recetas_postgres}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
RESTORE_DB="${RESTORE_DB:-auto}"
COMPOSE_UP="${COMPOSE_UP:-no}"
ENV_FILE_DEFAULT="$BASE_DIR/.env"
if [[ -z "${ENV_FILE:-}" && -f "$ENV_FILE_DEFAULT" ]]; then
  ENV_FILE="$ENV_FILE_DEFAULT"
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

echo "[INFO] Extrayendo $BACKUP_TAR"
tar -C "$WORKDIR" -xzf "$BACKUP_TAR"

echo "[INFO] Archivos extraídos (nivel 2):"
find "$WORKDIR" -maxdepth 2 -type f -printf '  - %P\n' || true

IMAGES_TAR="$(ls -1 "$WORKDIR"/docker/images_*.tar 2>/dev/null | head -n1 || true)"
DB_SQL="$(ls -1 "$WORKDIR"/database/pgdump_*.sql 2>/dev/null | head -n1 || true)"

# 1) Cargar imágenes
if [[ -n "$IMAGES_TAR" && -f "$IMAGES_TAR" ]]; then
  echo "[INFO] Cargando imágenes Docker desde: $IMAGES_TAR"
  docker load -i "$IMAGES_TAR"
  echo "[OK]   Imágenes cargadas"
else
  echo "[WARN] No se encontró tar de imágenes en $WORKDIR/docker"
fi

# 2) Restaurar volúmenes
VOLUMES_DIR="$WORKDIR/volumes"
if [[ -d "$VOLUMES_DIR" ]]; then
  shopt -s nullglob
  vol_files=("$VOLUMES_DIR"/*.tar.gz)
  if [[ ${#vol_files[@]} -gt 0 ]]; then
    echo "[INFO] Restaurando volúmenes (${#vol_files[@]})"
    echo "[WARN] Asegúrate de tener los contenedores detenidos (docker compose down) antes de restaurar volúmenes."
    for vf in "${vol_files[@]}"; do
      base="$(basename "$vf")"
      # Derivar nombre del volumen removiendo sufijo _YYYYMMDD_HHMMSS.tar.gz
      vol_name="${base%_????????_??????.tar.gz}"
      echo "[INFO] -> Volumen: $vol_name (archivo: $base)"
      if ! docker volume inspect "$vol_name" >/dev/null 2>&1; then
        docker volume create "$vol_name" >/dev/null
        echo "[INFO]    Volumen creado: $vol_name"
      fi
      docker run --rm \
        -v "$vol_name:/volume" \
        -v "$VOLUMES_DIR:/backup" \
        alpine sh -c "set -e; rm -rf /volume/*; tar -xzf /backup/$base -C /volume"
      echo "[OK]   Volumen restaurado: $vol_name"
    done
  else
    echo "[WARN] No hay archivos de volúmenes en $VOLUMES_DIR"
  fi
else
  echo "[WARN] Carpeta de volúmenes no encontrada: $VOLUMES_DIR"
fi

# 3) Restaurar DB (opcional)
if [[ -n "$DB_SQL" && -f "$DB_SQL" ]]; then
  do_restore_db="no"
  if [[ "$RESTORE_DB" == "yes" ]]; then
    do_restore_db="yes"
  elif [[ "$RESTORE_DB" == "auto" ]]; then
    # Si NO se restauró el volumen de Postgres, intentar importar DB
    # Heurística: si existe un archivo de volumen de postgres_data entre los extraídos
    if ls -1 "$WORKDIR"/volumes/*postgres*data_*.tar.gz >/dev/null 2>&1; then
      echo "[INFO] Detectado volumen de Postgres restaurado. Omitiendo importación SQL (RESTORE_DB=auto)."
      do_restore_db="no"
    else
      do_restore_db="yes"
    fi
  fi

  if [[ "$do_restore_db" == "yes" ]]; then
    echo "[INFO] Restaurando DB desde: $DB_SQL"
    if docker ps --format '{{.Names}}' | grep -qx "$POSTGRES_CONTAINER_NAME"; then
      docker exec -i "$POSTGRES_CONTAINER_NAME" sh -lc "psql -U '$POSTGRES_USER' -d '$POSTGRES_DB'" < "$DB_SQL"
      echo "[OK]   Dump importado en $POSTGRES_CONTAINER_NAME ($POSTGRES_DB)"
    else
      echo "[WARN] Contenedor Postgres '$POSTGRES_CONTAINER_NAME' no está ejecutándose. Omitiendo importación."
    fi
  fi
else
  echo "[WARN] No se encontró dump SQL en $WORKDIR/database"
fi

# 4) Levantar stack (opcional) si hay compose y el usuario lo pide
CONFIG_DIR="$WORKDIR/config"
# 4) Copiar SIEMPRE configuración al DEPLOY_DIR para dejar artefactos listos
compose_src=""
compose_name="docker-compose.prod.yml"
if [[ -f "$CONFIG_DIR/docker-compose.prod.yml" ]]; then
  compose_src="$CONFIG_DIR/docker-compose.prod.yml"
  compose_name="docker-compose.prod.yml"
elif [[ -f "$CONFIG_DIR/docker-compose.yml" ]]; then
  compose_src="$CONFIG_DIR/docker-compose.yml"
  compose_name="docker-compose.yml"
fi

echo "[INFO] Preparando directorio de despliegue: $DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"
if [[ -n "$compose_src" ]]; then
  cp -f "$compose_src" "$DEPLOY_DIR/$compose_name"
  echo "[OK]   Compose dejado en: $DEPLOY_DIR/$compose_name"
else
  echo "[WARN] No se encontró archivo docker-compose en $CONFIG_DIR"
fi
if [[ -f "$CONFIG_DIR/servers.json" ]]; then
  mkdir -p "$DEPLOY_DIR/pgadmin"
  cp -f "$CONFIG_DIR/servers.json" "$DEPLOY_DIR/pgadmin/servers.json"
  echo "[OK]   pgAdmin servers.json dejado en: $DEPLOY_DIR/pgadmin/servers.json"
fi

# 5) Levantar stack si así se solicitó
if [[ "$COMPOSE_UP" == "yes" && -n "$compose_src" ]]; then
  echo "[INFO] Levantando stack con: $DEPLOY_DIR/$compose_name"
  if [[ -n "${ENV_FILE:-}" && -f "$ENV_FILE" ]]; then
    (cd "$DEPLOY_DIR" && docker compose -f "$compose_name" --env-file "$ENV_FILE" up -d)
  else
    (cd "$DEPLOY_DIR" && docker compose -f "$compose_name" up -d)
  fi
  echo "[OK]   Stack levantado"
else
  if [[ "$COMPOSE_UP" != "yes" ]]; then
    echo "[INFO] Compose no ejecutado automáticamente. Puedes usar:"
    echo "       docker compose -f $DEPLOY_DIR/$compose_name --env-file ${ENV_FILE:-$DEPLOY_DIR/.env} up -d"
  fi
fi

echo "[DONE] Restauración completada"
