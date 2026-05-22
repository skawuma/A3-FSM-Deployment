# User Stories

## Purpose

This document describes the main user stories for the A3 Field Service Management platform. The stories are grouped by role so the product behavior can be understood from the point of view of the people using the system.

## User Roles

- Admin: manages work orders, users, technicians, and operational corrections.
- Dispatcher: assigns work, tracks workload, and monitors urgent field activity.
- Technician: performs assigned work in the field and submits completion evidence.
- Management: reviews operational performance, SLA pressure, and trends.

## Admin Stories

### Work Order Management

- As an admin, I want to create a work order so that a field service job can be tracked from request to completion.
- As an admin, I want to edit work order details so that incorrect or incomplete job information can be corrected.
- As an admin, I want to view all work orders so that I can monitor the full operational workload.
- As an admin, I want to cancel a work order so that invalid or unnecessary work does not remain active.
- As an admin, I want to reopen a completed work order so that follow-up work can be performed when the original job was not fully resolved.

### Assignment Oversight

- As an admin, I want to assign or reassign a technician so that work can be routed to the right person.
- As an admin, I want to view technician workload so that assignments can be balanced across the team.
- As an admin, I want to see work order history so that I can understand who changed a job and when.

### Reporting And Visibility

- As an admin, I want to view dashboard KPIs so that I can quickly understand current operational health.
- As an admin, I want to see overdue and due-today work so that urgent jobs can be handled first.
- As an admin, I want to review completion reports and attachments so that field work can be verified.

## Dispatcher Stories

### Dispatch Operations

- As a dispatcher, I want to assign a technician to an open work order so that the job can move into active execution.
- As a dispatcher, I want to unassign or return work to open status so that blocked or misassigned jobs can be corrected.
- As a dispatcher, I want to see due-today and overdue work so that I can prioritize time-sensitive jobs.
- As a dispatcher, I want to view technician workload so that I do not overload one technician while others are available.

### Live Operational Awareness

- As a dispatcher, I want dashboard updates to refresh when work changes so that I can respond without manually reloading the page.
- As a dispatcher, I want to see recent activity so that I can understand what changed across the operation.
- As a dispatcher, I want assignment and completion changes to appear quickly so that the office view stays aligned with the field.

## Technician Stories

### Field Execution

- As a technician, I want to view my assigned work orders so that I know what jobs I am responsible for.
- As a technician, I want to open work order details so that I can see location, priority, due date, and job instructions.
- As a technician, I want to start work from the field so that the job status reflects that execution has begun.
- As a technician, I want to save working notes so that important field observations are not lost.
- As a technician, I want to upload attachments and evidence so that completed work can be documented.
- As a technician, I want to submit a structured completion report so that the office receives consistent job information.
- As a technician, I want to capture a customer or field signature so that job completion can be confirmed.

### Exception Handling

- As a technician, I want to return a job to open status when work cannot proceed so that dispatch can reassign or reschedule it.
- As a technician, I want clear status feedback after I start or complete work so that I know the system saved my action.
- As a technician, I want role-appropriate access so that I only see and change the work relevant to my responsibilities.

## Management Stories

### Operational Review

- As management, I want to view KPI summaries so that I can understand current service performance.
- As management, I want to review status and priority analytics so that I can see where work is concentrated.
- As management, I want to view completion trends so that I can understand execution over time.
- As management, I want to monitor SLA pressure so that overdue work can be addressed before it affects service quality.

## Acceptance Themes

- Work order state changes must follow the approved lifecycle.
- Users must only access screens and actions allowed by their role.
- Field completion must capture enough information to support audit-friendly reporting.
- Dashboard data must reflect backend workflow state, not only frontend assumptions.
- Realtime updates should improve visibility without replacing backend validation.
