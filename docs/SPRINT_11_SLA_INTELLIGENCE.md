# Sprint 11 — SLA Intelligence

## Outcome

Sprint 11 turns SLA from a scheduled-date overdue flag into distinct business clocks across the work-order lifecycle. Scheduled date remains useful for planning, but it is not used as the execution SLA timer.

## Business clocks

| Clock | Starts | Ends | Purpose |
|---|---|---|---|
| Time to Assign | `createdAt` | `assignedAt` | Measures dispatch speed |
| Time to Embark / Start | `assignedAt` | `slaClockStartedAt` | Measures technician response time |
| Execution SLA | Policy-selected `slaClockStartedAt` | `completedAt` | Measures active service delivery |
| Resolution Time | `createdAt` | `completedAt` | Measures the full customer lifecycle |

The Sprint 11 policy starts the execution clock when a technician selects **Start Travel**. The backend also supports starting directly from assigned work for backward compatibility; in that path the policy anchor is work start.

Default execution allowances are priority based:

| Priority | Duration |
|---|---:|
| Critical | 60 minutes |
| High | 120 minutes |
| Medium / unspecified | 240 minutes |
| Low | 480 minutes |

## Lifecycle

`OPEN → ASSIGNED → EN_ROUTE → ARRIVED → WORK_STARTED → COMPLETED`

`IN_PROGRESS` remains readable as a legacy value so existing production records can be completed safely. New technician actions write the Sprint 11 statuses.

## Delivery map

| Brief phase | Delivered implementation |
|---|---|
| A — Data model | Lifecycle timestamps, execution fields, new statuses, Flyway V8 migration, indexes and constraints |
| B — Technician actions | `PATCH /start-travel`, `/arrive-onsite`, `/start-work`, plus completion |
| C — Calculation | Priority policy, due time, time-to-assign, time-to-embark, execution duration, resolution time and breach minutes |
| D — Dashboard | Near breach, active breach, completed within SLA, clock averages and technician compliance |
| E — Notifications | Scheduled near-breach and breach WebSocket alerts plus completion SLA outcome |
| F — Timeline | Travel, arrival, work start, SLA met and SLA breached events |
| G — Demo polish | Sprint 10 demo seed extended with running, near-breach, breached, met and late-completion scenarios |

## Deployment order

1. Publish Sprint 11 backend and frontend images.
2. Back up PostgreSQL.
3. Pull the images and recreate backend/frontend containers.
4. Confirm Flyway V8 applied successfully.
5. Verify `/actuator/health`, `GET /api/dashboard/sla-intelligence`, and the technician action sequence.
6. Confirm the WebSocket dashboard receives near-breach/breach activity.

Rollback must use the pre-deployment database backup because V8 adds persistent lifecycle data and constraints.

## Portfolio explanation

Sprint 11 introduces SLA Intelligence into the A3 Field Service Management platform. The system tracks creation, assignment, technician travel, arrival, work start, and completion as separate operational milestones. It measures dispatch, response, execution, and full-resolution time; detects near-breach and breached work; and provides technician SLA performance analytics. This moves the platform beyond CRUD into field-service operations intelligence.
