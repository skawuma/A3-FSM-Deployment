#!/usr/bin/env sh
set -eu

COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.ghcr.yml}"
BACKUP_DIR="${BACKUP_DIR:-db_backups}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
BACKUP_FILE="${BACKUP_DIR}/a3fsm_${TIMESTAMP}.dump"

mkdir -p "$BACKUP_DIR"

docker compose -f "$COMPOSE_FILE" exec -T db sh -c \
  'pg_dump --format=custom --no-owner --no-acl --dbname="$POSTGRES_DB" --username="$POSTGRES_USER"' \
  > "$BACKUP_FILE"

printf 'Backup written to %s\n' "$BACKUP_FILE"
