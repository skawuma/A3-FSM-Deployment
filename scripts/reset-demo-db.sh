#!/usr/bin/env sh
set -eu

COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.ghcr.yml}"
COMPOSE_ENV_FILE="${COMPOSE_ENV_FILE:-.env.prod}"
BACKUP_DIR="${BACKUP_DIR:-db_backups}"
CONFIRMATION="${1:-}"

compose() {
  docker compose --env-file "$COMPOSE_ENV_FILE" -f "$COMPOSE_FILE" "$@"
}

if [ "$CONFIRMATION" != "--confirm-demo-reset" ]; then
  printf '%s\n' \
    'Refusing to reset the database without explicit confirmation.' \
    'Usage: ./scripts/reset-demo-db.sh --confirm-demo-reset'
  exit 2
fi

active_profiles="$(compose exec -T backend sh -c 'printf "%s" "$SPRING_PROFILES_ACTIVE"')"
demo_data_enabled="$(compose exec -T backend sh -c 'printf "%s" "$DEMO_DATA_ENABLED"')"

case ",$active_profiles," in
  *,demo,*) ;;
  *)
    printf 'Refusing reset: backend profile list does not include demo.\n' >&2
    exit 3
    ;;
esac

if [ "$demo_data_enabled" != "true" ]; then
  printf 'Refusing reset: DEMO_DATA_ENABLED is not true in the backend container.\n' >&2
  exit 4
fi

printf 'Creating a pre-reset database backup...\n'
COMPOSE_FILE="$COMPOSE_FILE" \
COMPOSE_ENV_FILE="$COMPOSE_ENV_FILE" \
BACKUP_DIR="$BACKUP_DIR" \
  ./scripts/backup-postgres.sh

backend_stopped=false
restore_backend() {
  if [ "$backend_stopped" = "true" ]; then
    printf 'Restoring backend service after interrupted reset...\n' >&2
    compose up -d backend >/dev/null
  fi
}
trap restore_backend EXIT INT TERM

printf 'Stopping backend while demo tables are reset...\n'
compose stop backend
backend_stopped=true

compose exec -T db sh -c '
  psql --set ON_ERROR_STOP=1 --username="$POSTGRES_USER" --dbname="$POSTGRES_DB" <<SQL
BEGIN;
TRUNCATE TABLE
  attachments,
  work_order_events,
  work_order_completions,
  work_orders,
  technicians,
  users
RESTART IDENTITY CASCADE;
COMMIT;
SQL
'

printf 'Starting backend so the guarded demo seeder can restore fake data...\n'
compose up -d backend
backend_stopped=false
trap - EXIT INT TERM

attempt=1
while [ "$attempt" -le 30 ]; do
  health="$(docker inspect --format '{{.State.Health.Status}}' a3fsm_backend_prod 2>/dev/null || true)"
  if [ "$health" = "healthy" ]; then
    printf 'Demo reset complete; backend is healthy.\n'
    exit 0
  fi
  sleep 2
  attempt=$((attempt + 1))
done

printf 'Demo rows were reset, but backend did not become healthy within 60 seconds.\n' >&2
exit 5
