#!/usr/bin/env bash
# Si el script se ejecuta con `sh` (p. ej. `sh stop_stack.sh`), algunas opciones
# como `set -o pipefail` o construcciones `[[ ... ]]` fallarán. Re-ejecutamos con
# bash si no estamos ya en él.
if [ -z "${BASH_VERSION-}" ]; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  else
    echo "[ERROR] Este script requiere bash, pero no se encuentra 'bash' en PATH."
    exit 1
  fi
fi
set -euo pipefail

# stop_stack.sh
# Detiene el stack de docker-compose para la aplicación Recetas.

APP_DIR="${APP_DIR:-/home/admin/api-recetas}"
LOG_FILE="${LOG_FILE:-/var/log/recetas-stack.log}"

# Selección de compose file: prod primero, luego default
if [[ -f "$APP_DIR/docker-compose.prod.yml" ]]; then
  COMPOSE_FILE="$APP_DIR/docker-compose.prod.yml"
elif [[ -f "$APP_DIR/docker-compose.yml" ]]; then
  COMPOSE_FILE="$APP_DIR/docker-compose.yml"
else
  COMPOSE_FILE="" # sin compose, activaremos plan B
fi

# Logging robusto
LOG_TARGET="$LOG_FILE"
LOG_DIR="$(dirname "$LOG_FILE")"
if mkdir -p "$LOG_DIR" 2>/dev/null && : >"$LOG_FILE" 2>/dev/null; then
  :
else
  LOG_TARGET="$APP_DIR/recetas-stack.log"
  mkdir -p "$APP_DIR" 2>/dev/null || true
  : >"$LOG_TARGET" 2>/dev/null || LOG_TARGET="/tmp/recetas-stack.log"
fi
exec >> "$LOG_TARGET" 2>&1

echo "[$(date --iso-8601=seconds)] stop_stack: iniciando"

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] docker no está instalado o no está en PATH"
  exit 1
fi

if [[ -n "$COMPOSE_FILE" ]]; then
  # Resolver comando compose (mismo criterio que start_stack.sh)
  COMPOSE_CMD="docker compose"
  if ! docker compose version >/dev/null 2>&1; then
    if command -v docker-compose >/dev/null 2>&1; then
      COMPOSE_CMD="docker-compose"
    else
      echo "[ERROR] No se encontró 'docker compose' ni 'docker-compose'"
      exit 1
    fi
  fi

  # Soporte para docker-compose.override.yml local (igual que en start)
  ALLOW_LOCAL_BUILD="${ALLOW_LOCAL_BUILD:-false}"
  OVERRIDE_FILE="$APP_DIR/docker-compose.override.yml"
  if [[ "$ALLOW_LOCAL_BUILD" =~ ^([Tt]rue|1)$ ]] && [[ -f "$OVERRIDE_FILE" ]]; then
    echo "[INFO] ALLOW_LOCAL_BUILD habilitado; usando override compose: $OVERRIDE_FILE"
    COMPOSE_FILES=("-f" "$COMPOSE_FILE" "-f" "$OVERRIDE_FILE")
  else
    if [[ -f "$OVERRIDE_FILE" ]]; then
      echo "[INFO] Existe $OVERRIDE_FILE pero ALLOW_LOCAL_BUILD!='true' -> se ignorará"
    fi
    COMPOSE_FILES=("-f" "$COMPOSE_FILE")
  fi

  echo "[INFO] Ejecutando: $COMPOSE_CMD ${COMPOSE_FILES[*]} down --remove-orphans"
  $COMPOSE_CMD "${COMPOSE_FILES[@]}" down --remove-orphans || echo "[WARN] compose down retornó error"
else
  echo "[WARN] No se encontró docker-compose*.yml en $APP_DIR, usando plan B (detener contenedores por nombre)"
  # Detener y eliminar contenedores conocidos del stack (extendido)
  for name in api-recetas-backend api-recetas-postgres api-recetas-redis api-recetas-pgadmin api-recetas-frontend; do
    if docker ps -a --format '{{.Names}}' | grep -qx "$name"; then
      echo "[INFO] Deteniendo contenedor: $name"
      docker stop "$name" || true
      echo "[INFO] Eliminando contenedor: $name"
      docker rm "$name" || true
    else
      echo "[INFO] Contenedor no presente: $name"
    fi
  done
fi

echo "[$(date --iso-8601=seconds)] stop_stack: completado"
echo "[INFO] Logs en: $LOG_TARGET"
exit 0
