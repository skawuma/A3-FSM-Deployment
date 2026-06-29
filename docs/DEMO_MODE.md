# Sprint 10 Demo Mode Runbook

## Purpose

Demo mode makes the public A3 FSM deployment safe and useful for portfolio visitors. It creates fake users and operational data, displays public demo credentials in the Angular login experience, and supports a controlled reset without exposing real customer information.

## Live deployment context

All VPS commands must use the authoritative production context:

```sh
cd /opt/a3-fsm/A3-FSM-Deployment
docker compose --env-file .env.prod -f docker-compose.ghcr.yml <command>
```

Do not print or commit `.env.prod`.

## Enable demo mode

Set these non-secret values in `.env.prod`:

```dotenv
BACKEND_IMAGE=ghcr.io/skawuma/a3-fsm-backend:sprint-10-demo-readiness
FRONTEND_IMAGE=ghcr.io/skawuma/a3-fsm-frontend:sprint-10-demo-readiness
SPRING_PROFILES_ACTIVE=prod,demo
DEMO_DATA_ENABLED=true
```

The backend seeds data only when both the `demo` Spring profile and `DEMO_DATA_ENABLED=true` are active. Normal production defaults remain `prod` and `false`.

## Public demo accounts

| Role | Email | Password |
|---|---|---|
| Admin | `admin.demo@a3fsm.com` | `DemoAdmin2026!` |
| Dispatcher | `dispatcher.demo@a3fsm.com` | `DemoDispatch2026!` |
| Technician | `tech.demo@a3fsm.com` | `DemoTech2026!` |

These credentials are intentionally public and contain no production secrets. Passwords are BCrypt-hashed before database storage.

## Seeded fake data

The idempotent demo seed includes:

- four technicians with active and inactive states;
- eight work orders across open, assigned, in-progress, completed, overdue, and unassigned scenarios;
- recent timeline activity and assignment/start/completion events;
- structured completion reports for completed work orders;
- only fictional companies, people, addresses, and service activity.

Permanent technician deletion is blocked while demo mode is active. Self-registration and admin bootstrap remain disabled.

## Manual reset

The reset script is deliberately destructive and must never be run against a non-demo database. It verifies the running backend profile and demo flag, creates a database backup, temporarily stops the backend, truncates application tables, and starts the backend so the demo seed runs again.

```sh
cd /opt/a3-fsm/A3-FSM-Deployment
./scripts/reset-demo-db.sh --confirm-demo-reset
```

The script does not remove Docker volumes and does not run `docker compose down`.

## Deployment verification

After publishing Sprint 10 backend and frontend images:

```sh
docker compose --env-file .env.prod -f docker-compose.ghcr.yml config --quiet
docker compose --env-file .env.prod -f docker-compose.ghcr.yml ps
```

Then confirm:

- backend, frontend, and database health checks are healthy;
- the demo banner appears on login and authenticated pages;
- all three demo accounts can sign in;
- dashboards show realistic seeded work orders and activity;
- the portfolio live-demo link opens `https://fsm.samuelkawuma.com`;
- Grafana remains protected and is not presented as a public demo account.
