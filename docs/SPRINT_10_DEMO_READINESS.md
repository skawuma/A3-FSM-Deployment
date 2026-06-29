# Sprint 10 — Demo Readiness Execution Map

## Goal

Make A3 FSM safe, understandable, and useful for any portfolio visitor: the live site explains that it is a demo, supplies role-based credentials, contains realistic fictional activity, and can be restored to a known state.

## Repository ownership

| Workstream | Repository | Sprint 10 branch |
|---|---|---|
| Demo users, data, and safeguards | `A3-Field-Service-Management-Backend` | `sprint-10-demo-readiness` |
| Banner and login experience | `A3-Field-Service-Management-Frontend` | `sprint-10-demo-readiness` |
| Compose flags, reset, and runbooks | `A3-FSM-Deployment` | `sprint-10-demo-readiness` |
| Portfolio project proof and links | `samsPortfolio` | `sprint-10-demo-readiness` |

The backend and frontend branches are based on the deployed `sprint-9-production-devops` branches. The deployment and portfolio branches are based on their current `main` branches.

## Phase map

### Phase A — Fictional operational data

Implemented:

- four technicians: James Carter, Maria Lopez, Daniel Brooks, and Aisha Morgan;
- eight work orders covering open, assigned, in-progress, completed, overdue, and unassigned states;
- timeline events for creation, assignment, start, and completion;
- two structured completion reports;
- relative dates so SLA and dashboard views remain meaningful over time;
- idempotent startup behavior to prevent duplicate records.

### Phase B — Public demo users

Implemented:

- Admin, Dispatcher, and Technician demo accounts;
- BCrypt password hashing through the existing encoder;
- disabled self-registration and disabled bootstrap-admin flow;
- permanent technician deletion blocked in demo mode.

### Phase C — Demo communication

Implemented:

- global public-demo banner;
- responsive login page with role descriptions;
- one-click credential selection for all three roles;
- explicit notice that data is fictional and changes may reset.

### Phase D — Reset strategy

Implemented but not executed against production:

- `scripts/reset-demo-db.sh`;
- explicit `--confirm-demo-reset` argument;
- runtime checks for the `demo` profile and `DEMO_DATA_ENABLED=true`;
- automatic pre-reset PostgreSQL backup;
- backend-only stop/start cycle;
- health verification after reseeding;
- no volume removal and no `docker compose down`.

### Phase E — Portfolio connection

Implemented locally:

- expanded A3 FSM project proof for public demo mode;
- clear demo-access guidance;
- live demo, architecture, case study, protected monitoring, and source links.

## Validation completed

- Backend compile: passed.
- Backend tests: 34 passed, including demo seed count and idempotency tests.
- Frontend TypeScript check: passed.
- Frontend production build: passed.
- Portfolio TypeScript check: passed.
- Portfolio production build: passed.
- GHCR and source-build Compose validation: passed.
- Reset script syntax validation: passed.
- Angular Karma browser run: blocked by a local Chrome/Karma ping timeout before reliable completion; production build and typecheck remain green.

## Production rollout gates

Do not deploy by merely changing `.env.prod`. Use this order:

1. Review and commit each repository on `sprint-10-demo-readiness`.
2. Push backend and frontend branches and wait for both GHCR images to publish.
3. Confirm these image tags exist:
   - `ghcr.io/skawuma/a3-fsm-backend:sprint-10-demo-readiness`
   - `ghcr.io/skawuma/a3-fsm-frontend:sprint-10-demo-readiness`
4. Back up the live PostgreSQL database and verify the dump with `pg_restore --list`.
5. Update `.env.prod` without printing or committing it:

   ```dotenv
   BACKEND_IMAGE=ghcr.io/skawuma/a3-fsm-backend:sprint-10-demo-readiness
   FRONTEND_IMAGE=ghcr.io/skawuma/a3-fsm-frontend:sprint-10-demo-readiness
   SPRING_PROFILES_ACTIVE=prod,demo
   DEMO_DATA_ENABLED=true
   ```

6. Validate the rendered Compose configuration.
7. Obtain explicit approval before recreating backend or frontend containers.
8. Verify backend, frontend, and database health.
9. Sign in with all three demo roles and verify seeded dashboard/workflow data.
10. Deploy the updated portfolio only after the live demo URL is verified.

## Definition of done

- [x] Realistic fictional work orders exist in code.
- [x] Admin, Dispatcher, and Technician demo users exist in code.
- [x] Login page shows demo credentials.
- [x] Demo banner is visible in the production frontend build.
- [x] Demo data has a guarded reset workflow.
- [x] Portfolio A3 FSM project entry is demo-ready in code.
- [x] Documentation explains demo mode and reset safety.
- [x] No real customer data or deployment secrets were added.
- [ ] Sprint 10 branches are committed and pushed.
- [ ] CI publishes both Sprint 10 GHCR images.
- [ ] A verified production backup exists.
- [ ] Live deployment uses the Sprint 10 images and demo profile.
- [ ] All three live demo logins pass smoke testing.
- [ ] Portfolio deployment points visitors to the verified live demo.
