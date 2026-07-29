# A3 FSM Deployment Notes

## Production Configuration

The live Hostinger VPS deployment is managed from:

```sh
cd /opt/a3-fsm/A3-FSM-Deployment
```

Its authoritative deployment context is:

- Compose file: `docker-compose.ghcr.yml`
- Environment file: `.env.prod`

Use both files for every live Compose operation:

```sh
docker compose --env-file .env.prod -f docker-compose.ghcr.yml <command>
```

Do not substitute `.env` or `docker-compose.prod.yml` when administering the live VPS stack. `.env.prod` contains live configuration and must never be committed to Git.

The local source-build production-shaped stack is a separate workflow:

1. Copy `.env.example` to `.env` and replace every placeholder.
2. Create `secrets/jwt_secret.txt` with a long random value:

   ```sh
   mkdir -p secrets
   openssl rand -base64 64 > secrets/jwt_secret.txt
   chmod 600 secrets/jwt_secret.txt
   ```

3. Start the local source-build stack:

   ```sh
   docker compose --env-file .env -f docker-compose.prod.yml up --build -d
   ```

Production defaults keep self-registration and admin bootstrap disabled. Only login and refresh-token exchange should remain public auth flows in a normal production deployment.

## Sprint 10 Demo Mode

The public portfolio demo uses the production configuration plus a dedicated demo profile:

```dotenv
SPRING_PROFILES_ACTIVE=prod,demo
DEMO_DATA_ENABLED=true
```

The demo profile seeds only fictional users, technicians, work orders, timeline events, and completion reports. The public credentials are displayed in the frontend login experience. Ordinary production remains `SPRING_PROFILES_ACTIVE=prod` with `DEMO_DATA_ENABLED=false`.

Resetting the demo database is backup-first and requires explicit confirmation:

```sh
./scripts/reset-demo-db.sh --confirm-demo-reset
```

Do not execute the reset against a non-demo database. See [`docs/DEMO_MODE.md`](docs/DEMO_MODE.md) for the complete activation, reset, and verification runbook.

## Health Checks

- Backend readiness: `http://localhost:8080/actuator/health/readiness` inside the Docker network.
- Frontend readiness: `http://localhost/healthz`.
- Compose waits for PostgreSQL and backend health before bringing dependent services fully online.

## Monitoring

Prometheus scrapes backend metrics from `/actuator/prometheus` every 15 seconds and also scrapes the PostgreSQL exporter. Grafana is available on port `3000` and auto-loads the `A3 FSM Operational Overview` dashboard from `observability/grafana/dashboards`.

Set these values in `.env.prod` for the live VPS deployment (or `.env` for the separate local source-build workflow):

```text
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=replace-with-a-strong-grafana-password
```

More detail lives in `MONITORING.md`. VPS deployment details live in `VPS_DEPLOYMENT.md`.

## Frontend Runtime

Caddy is the intended public HTTPS edge proxy for production. It owns ports `80` and `443`, terminates TLS, routes `/api/*`, `/ws*`, and approved health endpoints to the Spring Boot backend, and routes all SPA paths to the Angular frontend container.

The Angular frontend container still uses its bundled Nginx process internally to serve static files and fall back to `index.html` for SPA routes. That container-level Nginx is not the public VPS edge proxy.

## Database Persistence

PostgreSQL production data is stored in the named Docker volume `db_data_prod`. Uploaded files are stored in `uploads_prod`.

## Backups

Run an on-demand production backup:

```sh
./scripts/backup-postgres.sh
```

Backups are written to `db_backups/` as custom-format PostgreSQL dump files. The scripts default to `docker-compose.ghcr.yml`; set `COMPOSE_FILE=docker-compose.prod.yml` if you are using the local source-build stack.

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
