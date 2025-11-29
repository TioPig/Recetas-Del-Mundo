#!/usr/bin/env bash

# backup_recetas_stack.sh
# Respaldo completo del stack (imagenes Docker, dump Postgres, volumenes, configs y artefactos).
# No realiza subida remota; crea un tar.gz en ./backups listo para transferir.

set -euo pipefail

# --- Configuracion (sobrescribible por variables de entorno) ---
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
BACKUP_DIR="${BACKUP_DIR:-$ROOT_DIR/backups}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
TMP_DIR="$(mktemp -d "$BACKUP_DIR/backup_tmp.XXXXXX")"


# Contenedores / volumenes por defecto (ajusta si tu compose usa otros nombres)
POSTGRES_CONTAINER_NAME="${POSTGRES_CONTAINER_NAME:-api-recetas-postgres}"
POSTGRES_DB="${POSTGRES_DB:-api_recetas_postgres}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_VOLUME="${POSTGRES_VOLUME:-postgres_data}"
PGADMIN_VOLUME="${PGADMIN_VOLUME:-pgadmin_data}"
BACKEND_IMAGE_NAME="${BACKEND_IMAGE_NAME:-api-recetas_final-backend:latest}"
# Si FRONTEND_IMAGE no está definida, usar el valor real de producción
FRONTEND_IMAGE="${FRONTEND_IMAGE:-tiopig1324/recetas-del-mundo:frontend-latest}"
COMPOSE_FILE="${COMPOSE_FILE:-$ROOT_DIR/docker-compose.yml}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"

mkdir -p "$BACKUP_DIR"
mkdir -p "$TMP_DIR/staging" "$TMP_DIR/staging/database" "$TMP_DIR/staging/volumes" "$TMP_DIR/staging/docker" "$TMP_DIR/staging/config" "$TMP_DIR/staging/artifacts"

echo "[INFO] Backup root: $BACKUP_DIR"
echo "[INFO] Raiz repo: $ROOT_DIR"
echo "[INFO] Temporary staging: $TMP_DIR/staging"

# Cargar .env local si existe (quita CRLF si vienen de Windows)
# También eliminar BOM UTF-8 si existe (evita errores al ejecutar en Git Bash)
if [ -f "$ROOT_DIR/.env" ]; then
  echo "[INFO] Cargando $ROOT_DIR/.env"
  CLEAN_ENV="$(mktemp)"
  # Remover BOM en la primera línea y eliminar CRLF (compatible con bash/sed/tr)
  # Usamos $'...' en sed para soportar escape de bytes en bash
  sed $'1s/^\xEF\xBB\xBF//' "$ROOT_DIR/.env" | tr -d '\r' > "$CLEAN_ENV"
  # shellcheck disable=SC1090
  set -a; . "$CLEAN_ENV"; set +a
  rm -f "$CLEAN_ENV"
fi

# Helper para imprimir error y salir
fail() { echo "[ERROR] $*" >&2; rm -rf "$TMP_DIR"; exit 1; }

### 1) Dump de Postgres
DB_DUMP="$TMP_DIR/staging/database/pgdump_${POSTGRES_DB}_${TIMESTAMP}.sql"
echo "[INFO] Generando dump de Postgres desde contenedor: $POSTGRES_CONTAINER_NAME (db=$POSTGRES_DB)"
if docker ps -a --format '{{.Names}}' | grep -qx "$POSTGRES_CONTAINER_NAME"; then
  set +e
  if [ -n "${POSTGRES_PASSWORD:-}" ]; then
    docker exec -e PGPASSWORD="$POSTGRES_PASSWORD" "$POSTGRES_CONTAINER_NAME" sh -lc "pg_dump -U '$POSTGRES_USER' -d '$POSTGRES_DB'" > "$DB_DUMP"
  else
    docker exec "$POSTGRES_CONTAINER_NAME" sh -lc "pg_dump -U '$POSTGRES_USER' -d '$POSTGRES_DB'" > "$DB_DUMP"
  fi
  rc=$?
  set -e
  if [ $rc -ne 0 ]; then
    echo "[WARN] pg_dump fallo (rc=$rc). Se omitira el dump pero continuare con resto de backup."
    rm -f "$DB_DUMP" || true
  else
    gzip -9 "$DB_DUMP"
    echo "[OK] Dump generado: ${DB_DUMP}.gz"
  fi
else
  echo "[WARN] Contenedor $POSTGRES_CONTAINER_NAME no encontrado. Omitiendo pg_dump."
fi

### 2) Guardar imagenes Docker (priorizar contenedores en ejecucion)
IMAGES_FILE="$TMP_DIR/staging/docker/images_${TIMESTAMP}.txt"
echo "[INFO] Detectando imagenes relevantes (contenedores, compose y compose file)..."
mkdir -p "$TMP_DIR/staging/docker"
if command -v docker >/dev/null 2>&1; then
  # Build a union of images:
  #  - images used by running containers
  #  - images used by all containers (fallback)
  #  - images explicitly declared in docker-compose.yml (image: entries)
  > "$IMAGES_FILE"

  # images from running containers (preferred)
  docker ps -q | while read -r cid; do
    docker inspect "$cid" --format '{{.Config.Image}}' 2>/dev/null || true
  done | grep -v '^$' >> "$IMAGES_FILE" || true

  # also include images from all containers (in case some are stopped)
  docker ps -a -q | while read -r cid; do
    docker inspect "$cid" --format '{{.Config.Image}}' 2>/dev/null || true
  done | grep -v '^$' >> "$IMAGES_FILE" || true

  # parse docker-compose file for explicit image: entries (if compose file exists)
  if [ -f "$COMPOSE_FILE" ]; then
    # capture lines like 'image: name:tag' possibly with indentation
    grep -E '^[[:space:]]*image:' "$COMPOSE_FILE" 2>/dev/null | sed -E 's/^[[:space:]]*image:[[:space:]]*//' >> "$IMAGES_FILE" || true
    # try `docker compose` to list images referenced by the compose file (if available)
    if command -v docker >/dev/null 2>&1; then
      if docker compose -f "$COMPOSE_FILE" images --format "{{.Repository}}:{{.Tag}}" >/dev/null 2>&1; then
        docker compose -f "$COMPOSE_FILE" images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -v '^$' >> "$IMAGES_FILE" || true
      fi
    fi
  fi

  # normalize, remove empty lines and duplicates
  if [ -f "$IMAGES_FILE" ]; then
    awk 'NF' "$IMAGES_FILE" | sort -u > "${IMAGES_FILE}.uniq" || true
    mv "${IMAGES_FILE}.uniq" "$IMAGES_FILE" || true
  fi

  if [ -s "$IMAGES_FILE" ]; then
    echo "[INFO] Imagenes a guardar:"; sed -n '1,200p' "$IMAGES_FILE"
    # Save each image individually to avoid multi-image docker save failures
    # Asegurarse de incluir imágenes construidas localmente indicadas por variables de entorno
    # (p. ej. BACKEND_IMAGE, FRONTEND_IMAGE) que pueden no aparecer en los listados anteriores.
    if [ -n "${BACKEND_IMAGE_NAME:-}" ]; then echo "$BACKEND_IMAGE_NAME" >> "$IMAGES_FILE" || true; fi
    if [ -n "${FRONTEND_IMAGE:-}" ]; then echo "$FRONTEND_IMAGE" >> "$IMAGES_FILE" || true; fi
    # normalizar de nuevo tras posibles adiciones
    awk 'NF' "$IMAGES_FILE" | sort -u > "${IMAGES_FILE}.uniq" || true
    mv "${IMAGES_FILE}.uniq" "$IMAGES_FILE" || true
    while IFS= read -r img; do
      [ -z "$img" ] && continue
      # Trim possible surrounding quotes and whitespace
      img_clean=$(echo "$img" | sed -E 's/^\s+|\s+$//g; s/^"//; s/"$//')
      img="$img_clean"
      # sanitize filename safe for filesystem
      safe="$(echo "$img" | sed 's/[^a-zA-Z0-9_.-]/_/g')"
      out="$TMP_DIR/staging/docker/${safe}_${TIMESTAMP}.tar"
      echo "[INFO] Guardando imagen: $img -> $out"
      if docker save -o "$out" "$img" 2>/dev/null; then
        echo "[OK] Imagen guardada: $out"
      else
        echo "[WARN] Fallo docker save para imagen: $img. Intentando pull+save..."
        # try pulling then saving
        if docker pull "$img" 2>/dev/null && docker save -o "$out" "$img" 2>/dev/null; then
          echo "[OK] Imagen pull+save OK: $out"
        else
          echo "[ERROR] No se pudo guardar imagen: $img"
          rm -f "$out" || true
        fi
      fi
    done < "$IMAGES_FILE"
    # Also persist the final images list for restore convenience
    cp -f "$IMAGES_FILE" "$TMP_DIR/staging/docker/images_${TIMESTAMP}.txt" || true
  else
    echo "[WARN] No se detectaron imagenes para guardar. Aplicando lista por defecto." 
    # Fallback: incluir imágenes base conocidas y la imagen de backend configurada
    echo "postgres:15" >> "$IMAGES_FILE"
    echo "dpage/pgadmin4:latest" >> "$IMAGES_FILE"
    if [ -n "${BACKEND_IMAGE_NAME:-}" ]; then echo "$BACKEND_IMAGE_NAME" >> "$IMAGES_FILE"; fi
  fi
else
  echo "[WARN] docker no disponible en PATH. Omitiendo guardado de imagenes."
fi

### 3) Respaldar volumenes (detectar por prefijo o heuristica)
echo "[INFO] Detectando volumenes Docker para respaldo"
# Construir lista candidate basada en varias heuristicas:
#  - nombres exactos en POSTGRES_VOLUME y PGADMIN_VOLUME
#  - nombres que terminan en _${POSTGRES_VOLUME} o _${PGADMIN_VOLUME}
#  - nombres que contienen 'postgres' o 'pgadmin'
#  - nombres que empiezan con el directorio del repo (prefijo de compose)

PROJECT_DIR_BASENAME="$(basename "$ROOT_DIR")"
SANITIZED_PREFIX="$(echo "$PROJECT_DIR_BASENAME" | tr '[:upper:]-' '[:lower:]_' | sed 's/[^a-z0-9_]/_/g')"

vols_to_backup=""
if command -v docker >/dev/null 2>&1; then
  docker volume ls --format '{{.Name}}' | while IFS= read -r v; do
    # exact names
    if [ "$v" = "$POSTGRES_VOLUME" ] || [ "$v" = "$PGADMIN_VOLUME" ]; then
      echo "$v"
      continue
    fi
    # suffix match (project prefixed volumes like project_postgres_data)
    if echo "$v" | grep -E "_(?:${POSTGRES_VOLUME}|${PGADMIN_VOLUME})$" >/dev/null 2>&1; then
      echo "$v"
      continue
    fi
    # contains keywords
    if echo "$v" | grep -E "postgres|pgadmin" >/dev/null 2>&1; then
      echo "$v"
      continue
    fi
    # starts with project basename or sanitized prefix
    if echo "$v" | grep -E "^${PROJECT_DIR_BASENAME}_|^${SANITIZED_PREFIX}_" >/dev/null 2>&1; then
      echo "$v"
      continue
    fi
  done | sort -u > "$TMP_DIR/staging/volumes/vols_to_backup_${TIMESTAMP}.txt"
  vols_to_backup_file="$TMP_DIR/staging/volumes/vols_to_backup_${TIMESTAMP}.txt"
  if [ -s "$vols_to_backup_file" ]; then
    echo "[INFO] Volumenes detectados para respaldo:"; sed -n '1,200p' "$vols_to_backup_file"
  else
    echo "[WARN] No se detectaron volumenes por heuristica. Intentando nombres por defecto: $POSTGRES_VOLUME $PGADMIN_VOLUME"
    printf "%s\n" "$POSTGRES_VOLUME" "$PGADMIN_VOLUME" > "$vols_to_backup_file"
  fi
else
  echo "[WARN] docker no disponible; no se pueden listar volumenes. Usando nombres por defecto."
  printf "%s\n" "$POSTGRES_VOLUME" "$PGADMIN_VOLUME" > "$TMP_DIR/staging/volumes/vols_to_backup_${TIMESTAMP}.txt"
  vols_to_backup_file="$TMP_DIR/staging/volumes/vols_to_backup_${TIMESTAMP}.txt"
fi

while IFS= read -r vol; do
  [ -z "$vol" ] && continue
  if docker volume inspect "$vol" >/dev/null 2>&1; then
    out="$TMP_DIR/staging/volumes/${vol}_${TIMESTAMP}.tar.gz"
    echo "[INFO] Empaquetando volumen: $vol -> $out"
    # Usar postgres:15 en lugar de busybox (ya disponible en el sistema, evita rate limit de Docker Hub)
    if docker run --rm -v "$vol:/volume:ro" postgres:15 sh -c "cd /volume || exit 0; tar -czf - ." > "$out"; then
      echo "[OK] Volumen $vol empaquetado -> $out"
    else
      echo "[WARN] Fallo empaquetar volumen $vol via stdout redirection. Intentando metodo alternativo con contenedor temporal."
      tmpctr="backup_tmp_pack_${TIMESTAMP}"
      docker run -d --name "$tmpctr" -v "$vol:/volume" postgres:15 sleep 600 >/dev/null 2>&1 || true
      if docker cp "$tmpctr":/volume - > /dev/null 2>&1; then
        # Fallback: intentar copiar contenido via tar dentro del contenedor a un archivo en /tmp y luego docker cp out
        docker exec "$tmpctr" sh -c "cd /volume || exit 0; tar -czf /tmp/${vol}_${TIMESTAMP}.tar.gz ." || true
        docker cp "$tmpctr":/tmp/${vol}_${TIMESTAMP}.tar.gz "$out" || true
      fi
      docker rm -f "$tmpctr" >/dev/null 2>&1 || true
      if [ -f "$out" ]; then
        echo "[OK] Volumen $vol empaquetado (fallback) -> $out"
      else
        echo "[ERROR] No se pudo empaquetar el volumen $vol"
      fi
    fi
  else
    echo "[WARN] Volumen $vol no existe, se omite."
  fi
done < "$vols_to_backup_file"

### 4) Copiar archivos relevantes (compose, configs, jar)
echo "[INFO] Copiando configuracion y artefactos"
# Copy any docker-compose files (docker-compose.yml, docker-compose.prod.yml, etc.)
for dc in "$ROOT_DIR"/docker-compose*.yml; do
  if [ -f "$dc" ]; then
    cp -f "$dc" "$TMP_DIR/staging/config/" || true
  fi
done
if [ -f "$ROOT_DIR/pgadmin/servers.json" ]; then
  mkdir -p "$TMP_DIR/staging/config/pgadmin"
  cp -f "$ROOT_DIR/pgadmin/servers.json" "$TMP_DIR/staging/config/pgadmin/"
fi
if [ -f "$ROOT_DIR/Springboot/Dockerfile" ]; then
  cp -f "$ROOT_DIR/Springboot/Dockerfile" "$TMP_DIR/staging/config/"
fi
if [ -f "$ROOT_DIR/Springboot/pom.xml" ]; then
  cp -f "$ROOT_DIR/Springboot/pom.xml" "$TMP_DIR/staging/config/"
fi
JAR_DIR="$ROOT_DIR/Springboot/target"
if [ -d "$JAR_DIR" ]; then
  JAR_FILE="$(ls -1t "$JAR_DIR"/*.jar 2>/dev/null | grep -v '\.original$' | head -n1 || true)"
  if [ -n "$JAR_FILE" ]; then
    cp -f "$JAR_FILE" "$TMP_DIR/staging/artifacts/"
    (cd "$TMP_DIR/staging/artifacts" && sha256sum "$(basename "$JAR_FILE")" > SHA256SUMS.txt) || true
  fi
fi

### 5) Empaquetar final
OUTFILE="$BACKUP_DIR/complete_backup_${TIMESTAMP}.tar.gz"
echo "[INFO] Empaquetando todo en: $OUTFILE"
tar -C "$TMP_DIR/staging" -czf "$OUTFILE" .
echo "[OK] Backup creado: $OUTFILE"
ls -lh "$OUTFILE" || true

### 6) Retencion
echo "[INFO] Aplicando retencion de $RETENTION_DAYS dias en $BACKUP_DIR"
find "$BACKUP_DIR" -type f -name 'complete_backup_*.tar.gz' -mtime +"$RETENTION_DAYS" -print -delete || true

# Limpieza
rm -rf "$TMP_DIR"
echo "[OK] Backup completado exitosamente: $OUTFILE"