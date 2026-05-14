# Sprint 9 Deployment Notes

## Production Configuration

1. Copy `.env.example` to `.env` and replace every placeholder.
2. Create `secrets/jwt_secret.txt` with a long random value:

   ```sh
   mkdir -p secrets
   openssl rand -base64 64 > secrets/jwt_secret.txt
   chmod 600 secrets/jwt_secret.txt
   ```

3. Start the stack:

   ```sh
   docker compose -f docker-compose.prod.yml --env-file .env up --build -d
   ```

## Health Checks

- Backend readiness: `http://localhost:8080/actuator/health/readiness` inside the Docker network.
- Frontend readiness: `http://localhost/healthz`.
- Compose waits for PostgreSQL and backend health before bringing dependent services fully online.

## Monitoring

Prometheus scrapes backend metrics from `/actuator/prometheus` every 15 seconds and also scrapes the PostgreSQL exporter. Grafana is available on port `3000` and auto-loads the `A3 FSM Operational Overview` dashboard from `observability/grafana/dashboards`.

Set these values in `.env` before running production:

```text
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=replace-with-a-strong-grafana-password
```

More detail lives in `MONITORING.md`.

## Frontend Runtime

Nginx serves the Angular static production build, proxies `/api/` and `/ws` to the backend service, enables gzip compression, caches hashed static assets for one year, and falls back to `index.html` for SPA routes.

## Database Persistence

PostgreSQL production data is stored in the named Docker volume `db_data_prod`. Uploaded files are stored in `uploads_prod`.

## Backups

Run an on-demand production backup:

```sh
./scripts/backup-postgres.sh
```

Backups are written to `db_backups/` as custom-format PostgreSQL dump files.

## Restore

Restore from a backup:

```sh
./scripts/restore-postgres.sh db_backups/a3fsm_YYYYMMDDTHHMMSSZ.dump
```

The restore script recreates the configured database before loading the dump. Use it only when you intentionally want to replace the current database contents.

## Migration Management

Production enables Flyway and keeps Hibernate at `ddl-auto: validate`. This means schema changes should be added as versioned SQL files under:

```text
A3 Field Service Management Backend/src/main/resources/db/migration/
```

Use names like `V2__add_work_order_indexes.sql`. For an existing database, `SPRING_FLYWAY_BASELINE_ON_MIGRATE=true` lets Flyway adopt the current schema without trying to recreate it. After the baseline, new production schema changes should go through migrations instead of Hibernate auto-update.
