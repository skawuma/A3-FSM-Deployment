#!/usr/bin/env sh
set -eu

if [ "$#" -ne 1 ]; then
  printf 'Usage: %s path/to/backup.dump\n' "$0" >&2
  exit 64
fi

COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.ghcr.yml}"
BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
  printf 'Backup file not found: %s\n' "$BACKUP_FILE" >&2
  exit 66
fi

docker compose -f "$COMPOSE_FILE" exec -T db sh -c \
  'dropdb --if-exists --username="$POSTGRES_USER" "$POSTGRES_DB" && createdb --username="$POSTGRES_USER" "$POSTGRES_DB"'

docker compose -f "$COMPOSE_FILE" exec -T db sh -c \
  'pg_restore --clean --if-exists --no-owner --no-acl --dbname="$POSTGRES_DB" --username="$POSTGRES_USER"' \
  < "$BACKUP_FILE"

printf 'Restore completed from %s\n' "$BACKUP_FILE"
