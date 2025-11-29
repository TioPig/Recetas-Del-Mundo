#!/bin/sh
# Simple wait-for-postgres script
set -e
HOST=${1:-postgres}
PORT=${2:-5432}
USER=${3:-${POSTGRES_USER:-postgres}}
RETRIES=${4:-30}
SLEEP=${5:-2}

echo "Waiting for postgres at $HOST:$PORT as user $USER"
i=0
while [ $i -lt $RETRIES ]; do
  if pg_isready -h "$HOST" -p "$PORT" -U "$USER" >/dev/null 2>&1; then
    echo "Postgres is ready"
    exit 0
  fi
  i=$((i+1))
  echo "Waiting... ($i/$RETRIES)"
  sleep $SLEEP
done
echo "Timed out waiting for Postgres" >&2
exit 1
