#!/usr/bin/env bash

# Re-ejecutar con bash si fue invocado con sh (que no soporta 'pipefail')
if [ -z "${BASH_VERSION:-}" ]; then
  exec /usr/bin/env bash "$0" "$@"
fi

set -euo pipefail

# Restauracion de backup generado por backup_recetas_stack.sh/.ps1
# Este script restaura:
#  - Imagenes Docker (docker load)
#  - Volumenes Docker (desempaquetando cada tar.gz en el volumen)
#  - Dump de base de datos Postgres (opcional, si no restauraste el volumen o si deseas reimportar)
#
# Requisitos previos en el servidor Debian con Docker:
#  - Docker instalado y en ejecucion
#  - Contenedores detenidos antes de restaurar volumenes (docker compose down)
#  - Espacio suficiente en disco
#
# Uso:
#  restore_recetas_stack.sh /ruta/al/complete_backup_YYYYMMDD_HHMMSS.tar.gz [opciones]
#    Variables de entorno opcionales:
#      POSTGRES_CONTAINER_NAME (default: api-recetas-postgres)
#      POSTGRES_DB (default: api_recetas_postgres)
#      POSTGRES_USER (default: postgres)
#      RESTORE_DB (default: auto) -> auto|yes|no
#      COMPOSE_UP (default: no)   -> yes|no (si hay compose extraido)
#      ENV_FILE (default: auto)   -> ruta a .env para usar con compose (auto: usa $BASE_DIR/.env si existe)
#      BASE_DIR (default: /home/admin/api-recetas) -> directorio de trabajo en el servidor
#      DEPLOY_DIR (default: $BASE_DIR)            -> destino donde se dejara el compose antes de levantar

BASE_DIR="${BASE_DIR:-/home/admin/api-recetas}"
DEPLOY_DIR="${DEPLOY_DIR:-$BASE_DIR}"

BACKUP_TAR="${1:-}"
if [[ -z "$BACKUP_TAR" ]]; then
  # Intentar auto-descubrir el backup mas reciente en $BASE_DIR/backups
  if [[ -d "$BASE_DIR/backups" ]]; then
    BACKUP_TAR="$(ls -1t "$BASE_DIR"/backups/complete_backup_*.tar.gz 2>/dev/null | head -n1 || true)"
  fi
  if [[ -z "$BACKUP_TAR" ]]; then
    echo "Uso: $0 /ruta/a/complete_backup_YYYYMMDD_HHMMSS.tar.gz" >&2
    echo "También puedes colocarlo en $BASE_DIR/backups y el script intentará detectarlo automaticamente." >&2
    exit 1
  fi
fi

POSTGRES_CONTAINER_NAME="${POSTGRES_CONTAINER_NAME:-api-recetas-postgres}"
POSTGRES_DB="${POSTGRES_DB:-api_recetas_postgres}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
RESTORE_DB="${RESTORE_DB:-auto}"
COMPOSE_UP="${COMPOSE_UP:-no}"
ENV_FILE="${ENV_FILE:-auto}"

if [[ ! -f "$BACKUP_TAR" ]]; then
  echo "[ERROR] Archivo de backup no encontrado: $BACKUP_TAR" >&2
  exit 1
fi

echo "[INFO] Restaurando desde: $BACKUP_TAR"
WORKDIR="$(mktemp -d /tmp/restore_recetas.XXXXXX)"
trap "rm -rf '$WORKDIR'" EXIT

echo "[INFO] Extrayendo backup a: $WORKDIR"
tar -xzf "$BACKUP_TAR" -C "$WORKDIR" || {
  echo "[ERROR] Fallo al extraer el backup" >&2
  exit 1
}
echo "[OK] Backup extraido"

# Detectar comando docker compose vs docker-compose
DOCKER_COMPOSE_CMD=""
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  DOCKER_COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  DOCKER_COMPOSE_CMD="docker-compose"
else
  echo "[WARN] No se encontro comando 'docker compose' ni 'docker-compose'. Algunas operaciones pueden fallar." >&2
fi

## 1) Cargar imagenes - buscar todos los archivos .tar en la carpeta docker
echo "[INFO] Cargando imagenes Docker..."
images_loaded=0
if [[ -d "$WORKDIR/docker" ]]; then
  shopt -s nullglob
  image_files=("$WORKDIR"/docker/*.tar)
  if [[ ${#image_files[@]} -gt 0 ]]; then
    for img_file in "${image_files[@]}"; do
      base_img=$(basename "${img_file}")
      echo "[INFO] -> Cargando imagen: ${base_img}"
      if docker load -i "${img_file}" > "$WORKDIR/docker/${base_img}.load.out" 2>"$WORKDIR/docker/${base_img}.load.err"; then
        # parse loaded image name from output if present
        printf "%s\n" "$(<"$WORKDIR/docker/${base_img}.load.out")"
        echo "[OK]   Imagen cargada: ${base_img}"
        images_loaded=$((images_loaded+1))
      else
        echo "[WARN] No se pudo cargar: ${base_img}; ver $WORKDIR/docker/${base_img}.load.err"
        tail -n 50 "$WORKDIR/docker/${base_img}.load.err" || true
      fi
    done
    echo "[OK]   Total imagenes intentadas: ${#image_files[@]}, cargadas: $images_loaded"
  else
    echo "[WARN] No se encontraron archivos .tar de imagenes en $WORKDIR/docker"
  fi
else
  echo "[WARN] Carpeta docker no encontrada en el backup"
fi

# 2) Restaurar volumenes
VOLUMES_DIR="$WORKDIR/volumes"
if [[ -d "$VOLUMES_DIR" ]]; then
  shopt -s nullglob
  vol_files=("$VOLUMES_DIR"/*.tar.gz)
  if [[ ${#vol_files[@]} -gt 0 ]]; then
    echo "[INFO] Restaurando volumenes (${#vol_files[@]})"
    echo "[WARN] Asegurate de tener los contenedores detenidos (docker compose down) antes de restaurar volumenes."
    for vf in "${vol_files[@]}"; do
      base="$(basename "$vf")"
      # Derivar nombre del volumen removiendo sufijo _YYYYMMDD_HHMMSS.tar.gz u otros sufijos comunes
      vol_name="$(echo "$base" | sed -E 's/_[0-9]{8}_[0-9]{6}\.tar\.gz$//; s/_[0-9]{8}\.tar\.gz$//; s/\.tar\.gz$//')"
      # If derived name is empty, fall back to using the original base name without extension
      if [[ -z "$vol_name" ]]; then
        vol_name="$(echo "$base" | sed -E 's/\.tar\.gz$//')"
      fi
      echo "[INFO] -> Volumen: $vol_name (archivo: $base)"
      if ! docker volume inspect "$vol_name" >/dev/null 2>&1; then
        docker volume create "$vol_name" >/dev/null || echo "[WARN] No se pudo crear volumen $vol_name"
        echo "[INFO]    Volumen creado: $vol_name"
      fi

      echo "[INFO]    Restaurando desde archivo: $vf"
      # Prefer mount method; if it fails, try container+docker cp fallback
      if docker run --rm \
        --mount type=volume,source="$vol_name",target=/volume \
        --mount type=bind,source="$vf",target=/backup/backup.tar.gz,readonly \
        postgres:15 sh -c 'set -e; rm -rf /volume/*; tar -xzf /backup/backup.tar.gz -C /volume'; then
        echo "[OK]   Volumen restaurado (via --mount): $vol_name"
      else
        echo "[WARN] --mount fallo, intentando extraccion via contenedor temporal para $vol_name" >&2
        tmp_ctr="restore_tmp_$(date +%s)_$RANDOM"
        if ! docker run -d --name "$tmp_ctr" -v "$vol_name:/volume" postgres:15 sleep 600 >/dev/null; then
          echo "[ERROR] No se pudo crear contenedor temporal $tmp_ctr para $vol_name" >&2
          continue
        fi
        if ! docker cp "$vf" "$tmp_ctr:/backup.tar.gz"; then
          echo "[ERROR] docker cp fallo para $vf -> $tmp_ctr:/backup.tar.gz" >&2
          docker rm -f "$tmp_ctr" >/dev/null || true
          continue
        fi
        if ! docker exec "$tmp_ctr" sh -c 'rm -rf /volume/* && tar -xzf /backup.tar.gz -C /volume'; then
          echo "[ERROR] Extraccion dentro del contenedor temporal fallo para $vol_name" >&2
          docker rm -f "$tmp_ctr" >/dev/null || true
          continue
        fi
        docker rm -f "$tmp_ctr" >/dev/null || true
        echo "[OK]   Volumen restaurado (via contenedor temporal): $vol_name"
      fi
      echo "[OK]   Volumen restaurado: $vol_name"
    done
  else
    echo "[WARN] No hay archivos de volumenes en $VOLUMES_DIR"
  fi
else
  echo "[WARN] Carpeta de volumenes no encontrada: $VOLUMES_DIR"
fi

## 3) Restaurar DB (opcional)
## Buscar dump SQL (.sql | .sql.gz) en el backup extraido (cualquier subdirectorio)
DB_SQL=""
found_sql=$(find "$WORKDIR" -type f -iname 'pgdump*.sql*' -print -quit 2>/dev/null || true)
if [[ -n "$found_sql" ]]; then
  DB_SQL="$found_sql"
fi

if [[ -n "$DB_SQL" && -f "$DB_SQL" ]]; then
  do_restore_db="no"
  if [[ "$RESTORE_DB" == "yes" ]]; then
    do_restore_db="yes"
  elif [[ "$RESTORE_DB" == "auto" ]]; then
    # Si NO se restauro el volumen de Postgres, intentar importar DB
    # Heuristica: si existe un archivo de volumen de postgres_data entre los extraidos
    if ls -1 "$WORKDIR"/volumes/*postgres*data_*.tar.gz >/dev/null 2>&1; then
      echo "[INFO] Detectado volumen de Postgres restaurado. Omitiendo importacion SQL (RESTORE_DB=auto)."
      do_restore_db="no"
    else
      echo "[INFO] No se restauro volumen de Postgres. Importando dump SQL (RESTORE_DB=auto)."
      do_restore_db="yes"
    fi
  fi

  if [[ "$do_restore_db" == "yes" ]]; then
    echo "[INFO] Restaurando base de datos desde: $DB_SQL"
    if ! docker ps --format '{{.Names}}' | grep -qx "$POSTGRES_CONTAINER_NAME"; then
      echo "[WARN] Contenedor $POSTGRES_CONTAINER_NAME no en ejecucion. Intentando levantar con compose..." >&2
      if [[ -f "$WORKDIR/config/docker-compose.yml" && -n "$DOCKER_COMPOSE_CMD" ]]; then
        cp "$WORKDIR/config/docker-compose.yml" "$DEPLOY_DIR/" || true
        if [[ "$ENV_FILE" == "auto" && -f "$BASE_DIR/.env" ]]; then
          ENV_FILE="$BASE_DIR/.env"
        fi
        cd "$DEPLOY_DIR"
        if [[ -n "$ENV_FILE" && -f "$ENV_FILE" ]]; then
          $DOCKER_COMPOSE_CMD --env-file "$ENV_FILE" up -d postgres
        else
          $DOCKER_COMPOSE_CMD up -d postgres
        fi
        echo "[INFO] Esperando a que Postgres esté listo..."
        sleep 10
      else
        echo "[ERROR] No se puede levantar contenedor de Postgres. Compose no disponible o no encontrado." >&2
        exit 1
      fi
    fi

    # Descomprimir si es .gz
    if [[ "$DB_SQL" == *.gz ]]; then
      echo "[INFO] Descomprimiendo $DB_SQL..."
      UNCOMPRESSED_SQL="/tmp/restore_db_$(date +%s).sql"
      gunzip -c "$DB_SQL" > "$UNCOMPRESSED_SQL"
      DB_SQL="$UNCOMPRESSED_SQL"
    fi

    echo "[INFO] Importando SQL a $POSTGRES_DB..."
    if docker exec -i "$POSTGRES_CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$DB_SQL"; then
      echo "[OK] Base de datos restaurada"
    else
      echo "[WARN] Importacion de DB fallo. Verifica logs del contenedor." >&2
    fi

    if [[ -f "$UNCOMPRESSED_SQL" ]]; then
      rm -f "$UNCOMPRESSED_SQL"
    fi
  else
    echo "[INFO] Omitiendo importacion de DB (RESTORE_DB=$RESTORE_DB)"
  fi
else
  echo "[WARN] No se encontro dump SQL en el backup"
fi

# 4) Copiar archivos de configuracion al directorio de deployment
if [[ -d "$WORKDIR/config" ]]; then
  echo "[INFO] Copiando configuracion a $DEPLOY_DIR"
  mkdir -p "$DEPLOY_DIR"
  cp -r "$WORKDIR"/config/* "$DEPLOY_DIR/" 2>/dev/null || true
  echo "[OK] Archivos de configuracion copiados"
fi

# 5) Levantar servicios con docker compose (opcional)
if [[ "$COMPOSE_UP" == "yes" ]]; then
  if [[ -f "$DEPLOY_DIR/docker-compose.yml" && -n "$DOCKER_COMPOSE_CMD" ]]; then
    echo "[INFO] Levantando servicios con docker compose..."
    cd "$DEPLOY_DIR"
    if [[ "$ENV_FILE" == "auto" && -f "$BASE_DIR/.env" ]]; then
      ENV_FILE="$BASE_DIR/.env"
    fi
    if [[ -n "$ENV_FILE" && -f "$ENV_FILE" ]]; then
      $DOCKER_COMPOSE_CMD --env-file "$ENV_FILE" up -d
    else
      $DOCKER_COMPOSE_CMD up -d
    fi
    echo "[OK] Servicios levantados"
  else
    echo "[WARN] No se puede levantar compose: archivo no encontrado o comando no disponible"
  fi
else
  echo "[INFO] Servicios NO levantados automaticamente (COMPOSE_UP=$COMPOSE_UP)"
  echo "[INFO] Para levantar manualmente: cd $DEPLOY_DIR && docker compose up -d"
fi

echo "[OK] Restauracion completada exitosamente"