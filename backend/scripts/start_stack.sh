#!/usr/bin/env bash
# Re-exec with bash when invoked with sh to ensure bash-specific features work.
if [ -z "${BASH_VERSION-}" ]; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  else
    echo "[ERROR] Este script requiere bash, pero no se encuentra 'bash' en PATH."
    exit 1
  fi
fi
set -euo pipefail

# start_stack.sh
# Arranca el stack de docker-compose para la aplicación Recetas.

APP_DIR="${APP_DIR:-/home/admin/api-recetas}"
ENV_FILE="${ENV_FILE:-$APP_DIR/.env}"
LOG_FILE="${LOG_FILE:-/var/log/recetas-stack.log}"

# Selección de compose file: prod primero, luego default
if [[ -f "$APP_DIR/docker-compose.prod.yml" ]]; then
  COMPOSE_FILE="$APP_DIR/docker-compose.prod.yml"
elif [[ -f "$APP_DIR/docker-compose.yml" ]]; then
  COMPOSE_FILE="$APP_DIR/docker-compose.yml"
else
  COMPOSE_FILE="$APP_DIR/docker-compose.yml" # fallback informativo
fi

# Configurar logging robusto (fallback si /var/log no es escribible)
LOG_TARGET="$LOG_FILE"
LOG_DIR="$(dirname "$LOG_FILE")"
if mkdir -p "$LOG_DIR" 2>/dev/null && : >"$LOG_FILE" 2>/dev/null; then
  :
else
  LOG_TARGET="$APP_DIR/recetas-stack.log"
  mkdir -p "$APP_DIR" 2>/dev/null || true
  : >"$LOG_TARGET" 2>/dev/null || LOG_TARGET="/tmp/recetas-stack.log"
fi
exec > >(tee -a "$LOG_TARGET") 2>&1

echo "[$(date --iso-8601=seconds)] start_stack: iniciando"

# Validar docker
if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] docker no está instalado o no está en PATH"
  exit 1
fi

# Resolver comando compose
COMPOSE_CMD="docker compose"
if ! docker compose version >/dev/null 2>&1; then
  if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
  else
    echo "[ERROR] No se encontró 'docker compose' ni 'docker-compose'"
    exit 1
  fi
fi

# Validar compose file
if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "[ERROR] No existe $COMPOSE_FILE -- nada que arrancar"
  exit 2
fi

# Mostrar entorno
if [[ -f "$ENV_FILE" ]]; then
  echo "[INFO] Usando ENV_FILE: $ENV_FILE"
  ENV_ARGS=(--env-file "$ENV_FILE")
else
  echo "[WARN] No existe $ENV_FILE, continuando sin --env-file"
  ENV_ARGS=()
fi

# Soporte para docker-compose.override.yml local (builds locales)
# Para evitar builds accidentales en producción, el override solo se considerará
# si la variable ALLOW_LOCAL_BUILD está explícitamente a 'true'.
ALLOW_LOCAL_BUILD="${ALLOW_LOCAL_BUILD:-false}"
OVERRIDE_FILE="$APP_DIR/docker-compose.override.yml"
if [[ "$ALLOW_LOCAL_BUILD" =~ ^([Tt]rue|1)$ ]] && [[ -f "$OVERRIDE_FILE" ]]; then
  echo "[INFO] ALLOW_LOCAL_BUILD habilitado; usando override compose: $OVERRIDE_FILE"
  COMPOSE_FILES=("-f" "$COMPOSE_FILE" "-f" "$OVERRIDE_FILE")
else
  if [[ -f "$OVERRIDE_FILE" ]]; then
    echo "[INFO] Existe $OVERRIDE_FILE pero ALLOW_LOCAL_BUILD!='true' -> se ignorará (no se harán builds locales)"
  fi
  COMPOSE_FILES=("-f" "$COMPOSE_FILE")
fi

echo "[INFO] Saltando el paso 'pull' por decisión del despliegue (haz pull externamente si corresponde)."

# Detener servicios existentes antes de levantar (evita conflictos de puertos/volúmenes)
echo "[INFO] Deteniendo servicios existentes..."
$COMPOSE_CMD "${COMPOSE_FILES[@]}" down --remove-orphans || echo "[WARN] docker compose down retornó error, continuando..."

echo "[INFO] Ejecutando: $COMPOSE_CMD ${COMPOSE_FILES[*]} up -d --remove-orphans"
$COMPOSE_CMD "${COMPOSE_FILES[@]}" "${ENV_ARGS[@]}" up -d --remove-orphans

echo "[$(date --iso-8601=seconds)] start_stack: completado"
echo "[INFO] Logs en: $LOG_TARGET"
exit 0
