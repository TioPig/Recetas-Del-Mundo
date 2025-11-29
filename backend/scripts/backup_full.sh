#!/usr/bin/env bash
set -euo pipefail

# Full backup script for the Recetas stack
# - DB dump (gzip)
# - Named volume archives (postgres volume)
# - Docker images used by project
# - Application JAR (from repo target or from backend container)
# - Compose files copy
# Usage: ./scripts/backup_full.sh [BACKUP_DIR]

BACKUP_DIR=${1:-/home/admin/api-recetas/backups}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"

# Try to source .env if available (to get DB name/user)
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE" || true
fi

# Defaults
POSTGRES_USER=${POSTGRES_USER:-${POSTGRES_USER:-postgres}}
POSTGRES_DB=${POSTGRES_DB:-${POSTGRES_DB:-api_recetas_postgres}}
PG_CONTAINER=${PG_CONTAINER:-api-recetas-postgres}
BACKEND_CONTAINER=${BACKEND_CONTAINER:-api-recetas-backend}

log(){ printf "[%s] %s\n" "$(date +'%Y-%m-%d %H:%M:%S')" "$*"; }

log "Backup started. Destination: $BACKUP_DIR"

## 1) DB dump (using docker exec to pg_dump)
DB_DUMP_FILE="$BACKUP_DIR/db_dump_${TIMESTAMP}.sql.gz"
if docker ps --format '{{.Names}}' | grep -q "${PG_CONTAINER}"; then
  log "Creating DB dump from container $PG_CONTAINER -> $DB_DUMP_FILE"
  docker exec -i "$PG_CONTAINER" pg_dump -U "${POSTGRES_USER}" "${POSTGRES_DB}" | gzip > "$DB_DUMP_FILE"
  log "DB dump written: $DB_DUMP_FILE"
else
  log "Warning: Postgres container '$PG_CONTAINER' not found. Skipping DB dump."
fi

## 2) Backup common named volumes (try a list of likely names)
VOLUME_CANDIDATES=(api-recetas_final_postgres_data api-recetas-postgres_data postgres_data api-recetas_final-postgres_data)
for vol in "${VOLUME_CANDIDATES[@]}"; do
  if docker volume inspect "$vol" >/dev/null 2>&1; then
    OUT="$BACKUP_DIR/${vol}_${TIMESTAMP}.tar.gz"
    log "Archiving volume $vol -> $OUT"
    docker run --rm -v "${vol}:/data:ro" -v "$BACKUP_DIR:/backup" alpine sh -c "cd /data && tar czf /backup/${vol}_${TIMESTAMP}.tar.gz ." >/dev/null
    log "Volume $vol archived"
  fi
done

## 3) Save docker images used by project containers
IMAGES_FILE="$BACKUP_DIR/images_${TIMESTAMP}.tar"
IMAGES=$(docker ps --format '{{.Names}} {{.Image}}' | grep -E 'api-recetas|recetas' || true)
if [ -n "$IMAGES" ]; then
  # collect unique image names
  IMGS="$(echo "$IMAGES" | awk '{print $2}' | sort -u | xargs)"
  if [ -n "$IMGS" ]; then
    log "Saving Docker images: $IMGS -> $IMAGES_FILE"
    docker save -o "$IMAGES_FILE" $IMGS
    log "Images saved to $IMAGES_FILE"
  fi
else
  log "No project containers found to save images from."
fi

## 4) Copy application JAR (prefer local target, fallback to container)
JAR_DST="$BACKUP_DIR/app_jar_${TIMESTAMP}.jar"
JAR_LOCAL="$(pwd)/Springboot/target/"
JAR_FOUND=""
if [ -d "$JAR_LOCAL" ]; then
  jarfile=$(ls "$JAR_LOCAL"*.jar 2>/dev/null | head -n1 || true)
  if [ -n "$jarfile" ]; then
    cp "$jarfile" "$JAR_DST"
    JAR_FOUND=1
    log "Copied local JAR $jarfile -> $JAR_DST"
  fi
fi
if [ -z "$JAR_FOUND" ]; then
  # try to copy from backend container
  if docker ps --format '{{.Names}}' | grep -q "${BACKEND_CONTAINER}"; then
    # common paths to search inside container
    CANDIDATE_PATHS=("/app.jar" "/app/*.jar" "/usr/local/lib/*.jar" "/opt/*.jar")
    for p in "${CANDIDATE_PATHS[@]}"; do
      set +e
      # try to copy first matching file
      file=$(docker exec "$BACKEND_CONTAINER" sh -c "ls $p 2>/dev/null || true" | head -n1 || true)
      set -e
      if [ -n "$file" ]; then
        log "Found jar in container: $file. Copying to $JAR_DST"
        docker cp "${BACKEND_CONTAINER}:$file" "$JAR_DST"
        JAR_FOUND=1
        break
      fi
    done
  fi
fi
if [ -z "$JAR_FOUND" ]; then
  log "JAR not found locally nor in container. Skipping JAR backup."
fi

## 5) Copy compose files and environment
for f in docker-compose.yml docker-compose.prod.yml docker-compose.override.yml .env; do
  if [ -f "$f" ]; then
    cp "$f" "$BACKUP_DIR/$(basename $f).${TIMESTAMP}"
    log "Copied $f to backup dir"
  fi
done

## 6) Create manifest
MANIFEST="$BACKUP_DIR/backup_manifest_${TIMESTAMP}.txt"
echo "Backup manifest - ${TIMESTAMP}" > "$MANIFEST"
echo "Hostname: $(hostname)" >> "$MANIFEST"
echo "Files in backup dir:" >> "$MANIFEST"
ls -lah "$BACKUP_DIR" >> "$MANIFEST" || true
log "Manifest created: $MANIFEST"

log "Backup finished. Files stored in $BACKUP_DIR"
echo
echo "Backup summary:"; ls -1 "$BACKUP_DIR" | sed -n '1,200p'

exit 0
