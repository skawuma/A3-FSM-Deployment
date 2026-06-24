# VPS Deployment Preparation

This runbook deploys A3 FSM using published GHCR images, Caddy HTTPS, PostgreSQL persistence, Prometheus, Grafana, and backup scripts.

## 1. DNS

Create DNS records pointing to the VPS public IP:

```text
fsm.example.com      A      <VPS_PUBLIC_IP>
grafana.example.com  A      <VPS_PUBLIC_IP>
```

Use your real hostnames in `.env`.

## 2. VPS Prerequisites

Install Docker Engine and the Docker Compose plugin on the VPS. Open only these inbound ports:

```text
22/tcp   SSH
80/tcp   HTTP for Caddy ACME challenge and redirect
443/tcp  HTTPS
```

Do not expose PostgreSQL, Prometheus, or Grafana directly to the internet. Caddy is the only public web edge.

## 3. Copy Deployment Repo

Clone or pull the deployment repo on the VPS:

```sh
git clone https://github.com/skawuma/A3-FSM-Deployment.git
cd A3-FSM-Deployment
```

## 4. Create Production Secrets

Create `.env` from `.env.example` and replace every placeholder:

```sh
cp .env.example .env
```

Required production values:

```text
APP_HOST=fsm.your-domain.com
GRAFANA_HOST=grafana.your-domain.com
ACME_EMAIL=you@example.com
DB_NAME=a3fsm
DB_USERNAME=<strong-db-user>
DB_PASSWORD=<strong-db-password>
APP_CORS_ALLOWED_ORIGINS=https://fsm.your-domain.com
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=<strong-grafana-password>
SPRING_FLYWAY_ENABLED=true
SPRING_FLYWAY_BASELINE_ON_MIGRATE=true
APP_AUTH_ALLOW_SELF_REGISTRATION=false
APP_AUTH_ALLOW_ADMIN_BOOTSTRAP=false
```

Create the JWT secret file:

```sh
mkdir -p secrets
openssl rand -base64 64 > secrets/jwt_secret.txt
chmod 600 secrets/jwt_secret.txt
```

## 5. GHCR Access

If the GHCR packages are private, log in on the VPS:

```sh
echo "<GITHUB_PAT_WITH_READ_PACKAGES>" | docker login ghcr.io -u skawuma --password-stdin
```

If packages are public, this step may not be needed.

## 6. Start The Stack

```sh
docker compose --env-file .env -f docker-compose.ghcr.yml pull
docker compose --env-file .env -f docker-compose.ghcr.yml up -d
```

Check health:

```sh
docker compose --env-file .env -f docker-compose.ghcr.yml ps
docker compose --env-file .env -f docker-compose.ghcr.yml logs --tail=100 backend
docker compose --env-file .env -f docker-compose.ghcr.yml logs --tail=100 caddy
```

## 7. One-Time Initial Admin

Production disables open admin bootstrap. For the first empty database only:

1. Set these values in `.env` temporarily:

   ```text
   APP_AUTH_ALLOW_ADMIN_BOOTSTRAP=true
   APP_AUTH_BOOTSTRAP_ADMIN_EMAIL=<your-admin-email>
   APP_AUTH_BOOTSTRAP_ADMIN_PASSWORD=<strong-temporary-admin-password>
   ```

2. Recreate the backend:

   ```sh
   docker compose --env-file .env -f docker-compose.ghcr.yml up -d backend
   ```

3. Call the bootstrap endpoint once:

   ```sh
   curl -X POST https://$APP_HOST/api/auth/create-admin
   ```

4. Immediately disable bootstrap again:

   ```text
   APP_AUTH_ALLOW_ADMIN_BOOTSTRAP=false
   APP_AUTH_BOOTSTRAP_ADMIN_EMAIL=
   APP_AUTH_BOOTSTRAP_ADMIN_PASSWORD=
   ```

5. Recreate the backend again:

   ```sh
   docker compose --env-file .env -f docker-compose.ghcr.yml up -d backend
   ```

6. Log in through the frontend and change the password if needed.

## 8. Backups

Run a manual backup:

```sh
./scripts/backup-postgres.sh
```

Restore from a backup:

```sh
./scripts/restore-postgres.sh db_backups/a3fsm_YYYYMMDDTHHMMSSZ.dump
```

Schedule backups with cron after the first successful production deploy.

## 9. Smoke Test

Before considering deployment complete:

- Frontend loads at `https://$APP_HOST`.
- Login works with the production admin user.
- Create a work order.
- Assign a technician.
- Complete a work order.
- Dashboard and realtime updates work.
- Prometheus targets are up.
- Grafana dashboard loads at `https://$GRAFANA_HOST`.
- Backup script produces a dump file.
