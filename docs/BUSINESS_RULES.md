# Business Rules

## Purpose

This document defines the core business rules for the A3 Field Service Management platform. These rules describe how work orders, assignments, technician actions, reporting, security, and dashboard behavior should operate.

## Work Order Lifecycle Rules

### Valid Statuses

The work order lifecycle is built around these primary statuses:

- `OPEN`: the work order exists but is not currently assigned or actively being worked.
- `ASSIGNED`: a technician has been assigned to the work order.
- `IN_PROGRESS`: a technician has started the work.
- `COMPLETED`: the work has been completed with required field documentation.
- `CANCELLED`: the work order has been cancelled and should no longer be executed.

### Allowed Transitions

- A new work order starts as `OPEN`.
- An `OPEN` work order can move to `ASSIGNED` when a technician is assigned.
- An `ASSIGNED` work order can move to `IN_PROGRESS` when the technician starts work.
- An `OPEN` work order can move to `IN_PROGRESS` directly when the platform allows technician self-start.
- An `IN_PROGRESS` work order can move to `COMPLETED` after completion details are submitted.
- An `ASSIGNED` work order can return to `OPEN` when work cannot proceed or assignment needs to be removed.
- An `OPEN` or `ASSIGNED` work order can move to `CANCELLED`.
- A `COMPLETED` work order can return to `OPEN` only when an admin reopens it.

### Restricted Transitions

- A completed work order should not be edited as active work unless it is reopened.
- A cancelled work order should not continue through technician execution.
- A work order should not be marked complete unless the required completion information has been submitted.
- Frontend status controls should guide the user, but backend services must enforce the actual workflow rules.

## Assignment Rules

- Only authorized admin or dispatch users should assign technicians.
- A work order should have a valid technician before moving into normal assigned execution.
- Reassignment should preserve history so that assignment changes remain auditable.
- Returning work to `OPEN` should remove the active assignment expectation and make the work available for dispatch review.
- Technician workload views should help prevent uneven assignment distribution.

## Technician Execution Rules

- A technician can start eligible work from the field.
- Starting work changes the status to `IN_PROGRESS` and creates a timeline or event record.
- Technicians can save notes while work is active.
- Technicians can upload evidence or attachments related to the work order.
- Completion requires structured completion information.
- Signature capture is part of final sign-off when required by the workflow.
- If work cannot proceed, the technician can return the job to `OPEN` for office review.

## Completion And Reporting Rules

- A completed work order should include enough field information to support review and reporting.
- Completion reports should be stored in a structured format rather than only as free-text notes.
- Attachments should be linked to the related work order.
- Work order events should provide an audit-friendly timeline of important changes.
- Dashboard activity should use backend events as the source of truth.

## SLA And Dashboard Rules

- Work orders with due dates should be evaluated for due-today and overdue status.
- SLA indicators should help admin and dispatch users prioritize urgent work.
- Dashboard KPI cards should summarize operational state from backend data.
- Analytics should include status distribution, priority distribution, and completion trends.
- Technician workload summaries should reflect current assignment and execution data.

## Realtime Rules

- Realtime updates should be published after important workflow actions are validated and saved.
- Realtime dashboard updates should reflect committed backend state.
- Assignment updates can notify affected users or update workload displays.
- Completion updates can refresh dashboards, recent activity, analytics, and work order lists.
- SLA alerts can surface overdue pressure to admin and dispatch views.
- Realtime messaging improves visibility but does not replace REST API validation.

## Security And Access Rules

- Users must authenticate before accessing protected platform features.
- JWT access and refresh tokens support authenticated API use.
- Role-based access should control navigation, screens, and allowed actions.
- Admin users have the broadest operational control.
- Dispatch users focus on assignment and operational monitoring.
- Technician users focus on assigned work and field execution.
- Sensitive workflow actions should be validated by the backend, even when the frontend hides unavailable controls.

## Data And Audit Rules

- PostgreSQL stores users, technicians, work orders, events, completion reports, and attachment metadata.
- Upload storage keeps field evidence files available beyond a single session.
- Important workflow actions should create event records.
- Reporting and dashboard data should be derived from persisted application state.
- Local Docker volumes should preserve uploaded evidence during container restarts.
