#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEMPLATE="$ROOT_DIR/pgadmin/servers.json.template"
OUT="$ROOT_DIR/pgadmin/servers.json"

if [ ! -f "$TEMPLATE" ]; then
  echo "[ERROR] Template not found: $TEMPLATE" >&2
  exit 1
fi

# Load .env if present
if [ -f "$ROOT_DIR/.env" ]; then
  # remove CRLF/BOM
  CLEAN_ENV="$(mktemp)"
  sed $'1s/^\xEF\xBB\xBF//' "$ROOT_DIR/.env" | tr -d '\r' > "$CLEAN_ENV"
  set -a; . "$CLEAN_ENV"; set +a
  rm -f "$CLEAN_ENV"
fi

# Prefer direct env var, fallback to .env loaded value
PASS="${POSTGRES_PASSWORD:-}" || PASS=""
if [ -z "$PASS" ]; then
  echo "[WARN] POSTGRES_PASSWORD not set in environment/.env. The generated servers.json will contain an empty password." >&2
fi

awk -v P="$PASS" '{ gsub(/<POSTGRES_PASSWORD>/, P); print }' "$TEMPLATE" > "$OUT"
chmod 600 "$OUT" || true
echo "[OK] Generated $OUT"
