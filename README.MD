# A3 Field Service Management Platform

## Plain-English Overview

A3 Field Service Management is a full-stack platform for coordinating service work from the office to the field.

It helps:

- admins create and manage work orders
- dispatchers assign the right technician to the right job
- technicians start work, capture notes, upload evidence, complete jobs, and sign off in the field
- technicians submit structured service reports and weekly timesheets
- admins and dispatchers review timesheets, mileage, signatures, and payroll-ready exports
- operations teams monitor workload, SLA pressure, execution trends, reporting, and payroll readiness from the dashboard

The project is split into two repositories:

- a Spring Boot backend for business rules, security, APIs, workflow enforcement, reporting, and timesheet automation
- an Angular frontend for the day-to-day role-based user experience

This workspace brings both together so the application can be developed, tested, deployed, and presented as one system.

## Visual Reading Guide

If someone is new to the project, the fastest way to understand it is to follow the diagrams in this order:

- start with the use case diagram to see who uses the platform and why
- move to the high-level architecture diagram to understand the current deployed shape
- review the work order lifecycle to understand how jobs move from creation to completion
- review the completion report lifecycle to understand how technician field reports are captured
- review the timesheet lifecycle to understand how completed work becomes payroll-ready weekly reporting
- finish with the realtime and dashboard diagrams to understand operational visibility

## Portfolio Snapshot

This project is strongest when explained from both a business and engineering angle:

- business problem: field teams need a clearer way to assign, execute, complete, report, and validate service work
- product solution: one shared platform for admin, dispatch, and technician users with role-aware workflows
- engineering value: strong backend workflow enforcement, structured reporting, timesheet automation, dashboard analytics, Docker packaging, and a clear realtime evolution path
- operational value: better visibility, cleaner reporting, stronger auditability, faster decision-making, and payroll-ready weekly exports

## Sprint 12 Product Experience

Sprint 12 applies a Figma-inspired enterprise SaaS design system to the proven Angular workflow instead of rebuilding the application. The release adds responsive navigation, clearer role-specific dashboard framing, operational reports, and downloadable CSV/PDF exports.

![Sprint 12 dispatcher dashboard](docs/screenshots/sprint-12-dashboard.png)

![Sprint 12 operations reports](docs/screenshots/sprint-12-reports.png)

Key delivery points:

- responsive desktop, tablet, and mobile application shell
- consistent design tokens, cards, tables, status badges, and spacing
- role-aware navigation and dashboard hierarchy
- date-filtered operations report API
- SLA, workload, and technician performance reporting
- CSV and designed multi-page PDF exports

See [Sprint 12 - Product Polish](docs/SPRINT_12_PRODUCT_POLISH.md) for the delivery map and verification checklist.

## Sprint 13 Timesheet Automation And Payroll Reporting

Sprint 13 extends the platform from field execution into payroll reporting. Completed work orders now become the source of truth for weekly technician timesheets, mileage review, and signed payroll-ready exports.

Key delivery points:

- weekly technician timesheet module
- automatic timesheet entry generation from completed work orders
- manual miles entry for technician travel reporting
- onsite and offsite timestamp capture
- break start and break end fields
- technician comments field
- technician signature capture for weekly submission
- admin review workflow for submitted timesheets
- weekly CSV export from the backend
- weekly PDF export from the Angular client
- production-quality AOP logging and Swagger/OpenAPI documentation for the Timesheet API
- A3/WWTS contract completion form generation remains a documented follow-up item on the Sprint 13 roadmap

Business value:

- reduces duplicate data entry between work orders, reports, and payroll records
- improves accuracy by using completed work orders as the source of truth
- gives admins a review step before payroll/export submission
- creates cleaner documentation for payroll, contractor review, and internal audit needs

## Why This Project Exists

In many field service teams, job coordination still happens across phone calls, spreadsheets, sticky notes, and memory. That creates a familiar set of problems:

- work orders are assigned late or inconsistently
- technicians do not always have a clean start-to-complete workflow
- notes and completion evidence are captured in different formats
- supervisors have limited visibility into overdue work
- timesheets and mileage records are often disconnected from the actual completed jobs
- reporting is delayed because the data is not structured

A3 FSM turns that into a traceable workflow with clear states, role-based actions, audit-friendly reporting, and payroll-ready weekly timesheet exports.

## Use Case Diagram

```mermaid
flowchart LR
    A[Admin] --> B[Create and edit work orders]
    D[Dispatch] --> C[Assign technician]
    T[Technician] --> E[Start work in the field]
    T --> F[Capture notes, attachments, onsite/offsite time, and service report]
    T --> G[Complete and sign off work order]
    T --> TS[Submit weekly timesheet]
    A --> H[Reopen or reassign when needed]
    A --> AR[Review reports and timesheets]
    D --> I[Track overdue and due-today work]
    M[Management] --> J[Review dashboard analytics and exports]
    P[Payroll or Operations] --> K[Use approved weekly CSV/PDF exports]

    B --> C --> E --> F --> G
    G --> R[Capture structured completion report]
    G --> TE[Auto-add completed job to weekly timesheet]
    TE --> TS --> AR --> K
    R --> J
    G --> J
    H --> B
    I --> C
```

## Core Capabilities

### Work Order Operations

- create, edit, and track work orders
- assign and unassign technicians
- move work through a controlled lifecycle
- reopen completed jobs when more work is needed
- connect completed work orders to completion reports and weekly timesheets

### Technician Execution

- start work without waiting for admin intervention
- save working notes while on site
- capture onsite and offsite timestamps
- upload attachments and evidence
- submit a structured completion report
- capture signature during final sign-off
- return a job to `OPEN` when work cannot proceed

### Completion Reports And Export Foundation

- capture structured completion reports from work order data
- capture FA tag or device details
- record whether the issue was resolved
- record replacement and return-visit requirements
- save technician summary notes
- preserve completed work order information for future A3/WWTS-style contract completion forms
- support PDF and CSV export for operational reports

### Timesheet And Payroll Reporting

- weekly timesheet view by technician and week
- automatic timesheet entries from completed work orders
- manual mileage entry
- break start and break end tracking
- comments and technician signature on submission
- admin or dispatch review, approval, and rejection
- weekly backend CSV export and frontend PDF export for payroll or contractor review

### Dashboard And Analytics

- operational KPI cards
- recent activity feed with dashboard-friendly text
- status, priority, and completion trend analytics
- SLA watch for overdue and due-today jobs
- technician workload overview and heatmap foundation
- role-aware dashboards for admin, dispatch, and technician users
- operational reports with CSV and PDF export for admin and dispatch users
- timesheet review queues for admin and dispatch users

The quick architecture view below shows the current deployed shape of the platform. A more detailed current-state and future-state view appears later in this README.

## Why This Project Stands Out

- it reflects a real field-service workflow instead of a generic CRUD demo
- it connects office operations, technician execution, reporting, and payroll readiness in one lifecycle
- it treats the backend as the source of truth while still delivering guided UI behavior
- it already shows product thinking, architecture thinking, and scalability thinking in one codebase
- it demonstrates how field data can move from dispatch assignment to completion report to approved weekly timesheet

## High-Level Architecture Diagram

```mermaid
flowchart TB
    U[Browser] --> F[Angular Frontend]
    F --> P[API Proxy or Nginx]
    P --> B[Spring Boot Backend]
    B --> DB[(PostgreSQL)]
    B --> FS[Uploads Storage]
    B --> JWT[JWT Access and Refresh Tokens]

    subgraph Backend Modules
        WO[Work Order Module]
        REP[Report Module]
        TS[Timesheet Module]
        DASH[Dashboard and Export Module]
    end

    B --> WO
    B --> REP
    B --> TS
    B --> DASH
    WO --> DB
    REP --> DB
    TS --> DB
    DASH --> DB

    subgraph DevOps
        DC[Docker Compose]
        PGA[pgAdmin]
    end

    DC --> F
    DC --> B
    DC --> DB
    PGA --> DB
```

## Sprint 8 Realtime Architecture

Sprint 8 stabilizes the platform as a modular monolith with event-driven realtime messaging.

```mermaid
flowchart TB
    subgraph Angular Frontend
        ML[Main Layout]
        RT[RealtimeService]
        DASH[Dashboard]
        LIST[Work Orders List]
        DETAIL[Work Order Detail]
        REPORTS[Reports Screen]
        TIMESHEETS[Timesheets Screen]
        TOAST[Toast Notifications]
    end

    subgraph Spring Boot Backend
        WO[WorkOrderService]
        RS[ReportService]
        TS[TimesheetService]
        DS[DashboardService]
        SLA[SlaRealtimeMonitor]
        PUB[RealtimeEventPublisher]
        WS[WebSocket STOMP Broker]
    end

    DB[(PostgreSQL)]

    ML --> RT
    RT <--> WS
    WO --> DB
    RS --> DB
    TS --> DB
    DS --> DB
    SLA --> DB
    WO --> PUB
    DS --> PUB
    SLA --> PUB
    PUB --> WS

    WS --> DASH
    WS --> LIST
    WS --> DETAIL
    WS --> TOAST
    REPORTS --> RS
    TIMESHEETS --> TS
```

### Realtime Channels

```mermaid
flowchart LR
    PUB[RealtimeEventPublisher] --> DASH_TOPIC[/topic/dashboard/]
    PUB --> ALERT_TOPIC[/topic/alerts/]
    PUB --> USER_QUEUE[/user/queue/notifications/]

    DASH_TOPIC --> DASH[Dashboard, list, and detail updates]
    ALERT_TOPIC --> ALERT[SLA breach alerts]
    USER_QUEUE --> TECH[Technician assignment notifications]

    REST[REST APIs] -. refresh on demand .-> REP[Reports screen]
    REST -. refresh on demand .-> TS[Timesheets screen]
```

### Realtime Business Flow

```mermaid
sequenceDiagram
    participant User as Admin, Dispatch, or Technician
    participant API as Spring Boot Service Layer
    participant Pub as RealtimeEventPublisher
    participant Broker as STOMP Broker
    participant UI as Connected Angular Screens

    User->>API: Create, assign, start, complete, or trigger SLA-relevant work
    API->>API: Validate role and workflow rules
    API->>Pub: Publish enriched realtime event after commit
    Pub->>Broker: /topic/dashboard, /topic/alerts, or /user/queue/notifications
    Broker-->>UI: Update dashboard, list, detail, alerts, and toast state

    User->>API: Review report or submit/approve/reject timesheet
    API-->>UI: REST response updates report or timesheet screen
```

## Repository Layout

```text
A3_SOLUTIONS_PROJECT/
|- A3-FSM-Deployment/
|  |- README.MD
|  |- docker-compose.dev.yml
|  |- docker-compose.prod.yml
|  |- .env
|  |- docs/
|  `- observability/
|- A3-Field-Service-Management-Backend/
|  |- README.MD
|  `- src/...
`- A3-Field-Service-Management-Frontend/
   |- README.md
   `- src/...
```

## High-Level Technical View

### Frontend

- Angular application with role-based routing and guarded screens
- dashboard, work order, technician, reports, timesheets, and authentication modules
- JWT-aware HTTP layer and session timeout behavior
- dashboard visualizations using summary, activity, analytics, SLA, and workload endpoints
- report and timesheet screens that consume dedicated REST APIs and export utilities

### Backend

- Spring Boot REST API
- business rules enforced in the service layer
- PostgreSQL persistence with audit-style work order events
- JWT authentication and refresh-token support
- dashboard aggregation endpoints for operational and analytical views
- ReportService for operational reporting
- TimesheetService for weekly payroll review, CSV export, AOP logging, and OpenAPI-documented workflows

### Infrastructure

- Docker Compose for frontend, backend, database, pgAdmin, and observability services
- split development and production-oriented compose files at the root workspace
- local uploads volume for evidence files and generated export artifacts
- local font bundling to avoid external Google Fonts build issues during containerized builds

## Work Order Lifecycle Flowchart

This is the core operational heartbeat of the platform.

```mermaid
stateDiagram-v2
    [*] --> OPEN
    OPEN --> ASSIGNED: dispatch assigns technician
    ASSIGNED --> EN_ROUTE: technician starts travel
    EN_ROUTE --> ARRIVED: technician arrives onsite
    ARRIVED --> WORK_STARTED: technician starts work
    WORK_STARTED --> COMPLETION_DRAFT: technician enters notes, report details, evidence
    COMPLETION_DRAFT --> COMPLETED: report + signature submitted
    COMPLETED --> TIMESHEET_PENDING: auto-add to weekly timesheet

    ASSIGNED --> OPEN: return to open
    EN_ROUTE --> OPEN: unable to proceed
    ARRIVED --> OPEN: site issue or blocked work
    WORK_STARTED --> OPEN: work cannot be completed
    OPEN --> CANCELLED: cancel
    ASSIGNED --> CANCELLED: cancel
    COMPLETED --> OPEN: admin reopens
```

## Technician Completion Flow

```mermaid
sequenceDiagram
    participant Tech as Technician
    participant UI as Angular UI
    participant API as Spring Boot API
    participant DB as PostgreSQL
    participant TS as Timesheet Service

    Tech->>UI: Open assigned work order
    UI->>API: Load work order detail
    API->>DB: Fetch work order, attachments, timeline, and report state
    DB-->>API: Work order data
    API-->>UI: Detail response

    Tech->>UI: Start travel / arrive / start work
    UI->>API: POST workflow action
    API->>DB: Update status, SLA clocks, and event log
    DB-->>API: Saved
    API-->>UI: Updated detail

    Tech->>UI: Enter completion report, evidence, and signature
    UI->>API: Submit completion report
    API->>DB: Validate state and save report
    API->>DB: Mark work order COMPLETED and log event
    API->>TS: Create or update weekly timesheet entry
    TS->>DB: Save auto-generated row with work date and site context
    API-->>UI: Work order completed and timesheet entry created
```

## Completion Report Lifecycle Flowchart

The completion report lifecycle documents the service outcome before the work order is signed off. The current implementation captures structured report data and links it to the completed work order; A3/WWTS contract form generation is the next template-driven follow-up.

```mermaid
stateDiagram-v2
    [*] --> NOT_STARTED
    NOT_STARTED --> DRAFT: technician opens completion form
    DRAFT --> SUBMITTED: technician submits FA tag, outcome, and summary
    SUBMITTED --> WORK_ORDER_COMPLETION: completion report satisfies sign-off prerequisite
    WORK_ORDER_COMPLETION --> SIGNED_OFF: technician signature completes work order
    SIGNED_OFF --> REPORTING_SOURCE: report powers operations reporting and audit review
    REPORTING_SOURCE --> A3_WWTS_TEMPLATE: roadmap follow-up
```

## Completion Report Submission Sequence

```mermaid
sequenceDiagram
    participant Tech as Technician
    participant UI as Work Order Detail UI
    participant API as Work Order Completion API
    participant DB as PostgreSQL
    participant Reports as Operations Reports

    Tech->>UI: Fill FA tag, resolved status, replacement, return visit, summary, signature
    UI->>API: POST structured completion report
    API->>DB: Save structured report and link to work order
    API->>DB: Log report submitted event
    API-->>UI: Report submitted

    Tech->>UI: Complete and sign work order
    UI->>API: POST completion sign-off
    API->>DB: Mark work order COMPLETED
    Reports->>DB: Read completed work orders and completion context for exports
```

## Timesheet Lifecycle Flowchart

The timesheet lifecycle converts completed field work into a weekly payroll-ready record.

```mermaid
stateDiagram-v2
    [*] --> WEEK_OPEN
    WEEK_OPEN --> AUTO_POPULATED: completed work orders added
    AUTO_POPULATED --> TECH_EDITING: technician adds miles, breaks, comments
    TECH_EDITING --> SIGNED: technician signs weekly timesheet
    SIGNED --> SUBMITTED: technician submits timesheet
    SUBMITTED --> REVIEW: admin or dispatch reviews hours, miles, and comments
    REVIEW --> APPROVED: reviewer approves
    REVIEW --> REJECTED: reviewer rejects
    REJECTED --> TECH_EDITING: technician corrects and resubmits
    APPROVED --> LOCKED: timesheet locked against technician edits
    LOCKED --> EXPORTED: CSV downloaded or PDF generated
```

## Timesheet Automation Sequence

```mermaid
sequenceDiagram
    participant WO as Work Order Service
    participant TS as Timesheet Service
    participant DB as PostgreSQL
    participant Tech as Technician
    participant Reviewer as Admin or Dispatch
    participant Export as CSV API / PDF Client

    WO->>TS: Work order completed event
    TS->>DB: Find technician weekly timesheet by completion week
    alt Timesheet exists
        TS->>DB: Add or update timesheet entry
    else No timesheet exists
        TS->>DB: Create weekly timesheet and add entry
    end

    Tech->>TS: Add miles, break start/end, comments, and signature
    TS->>DB: Save technician submission
    Reviewer->>TS: Review submitted weekly timesheet
    alt Approved
        TS->>DB: Mark APPROVED and lock technician edits
        Export->>TS: Download backend CSV or generate frontend PDF
    else Rejected
        TS->>DB: Mark REJECTED for technician correction
    end
```

## Dashboard Layers

The dashboard is intentionally evolving in layers so it remains useful for operations today and extensible for analytics tomorrow.

```mermaid
flowchart LR
    A[Operational Layer] --> A1[KPI cards]
    A --> A2[Recent activity]
    A --> A3[SLA watch]
    A --> A4[Technician workload]

    B[Analytical Layer] --> B1[Status distribution]
    B --> B2[Priority distribution]
    B --> B3[Completion trend]
    B --> B4[Operations reports]
    B --> B5[Timesheet review queue]

    C[Role Awareness] --> C1[Admin global view]
    C --> C2[Dispatch operational view]
    C --> C3[Technician personal view]

    D[Payroll Readiness] --> D1[Submitted timesheets]
    D --> D2[Approved hours]
    D --> D3[Mileage totals]
    D --> D4[Weekly PDF and CSV exports]
```

## Current Data Model Overview

```mermaid
erDiagram
    USER ||--o| TECHNICIAN : maps_to
    TECHNICIAN ||--o{ WORK_ORDER : assigned_to
    WORK_ORDER ||--o{ WORK_ORDER_EVENT : records
    WORK_ORDER ||--o| COMPLETION_REPORT : produces
    TECHNICIAN ||--o{ TIMESHEET : owns
    TIMESHEET ||--o{ TIMESHEET_ENTRY : contains
    WORK_ORDER ||--o| TIMESHEET_ENTRY : creates

    WORK_ORDER {
        bigint id
        string clientName
        string address
        string status
        string priority
        datetime openedAt
        datetime slaDueAt
        datetime completedAt
    }

    COMPLETION_REPORT {
        bigint id
        bigint workOrderId
        string faTag
        boolean issueResolved
        string replacementNeeded
        boolean returnVisitRequired
        string summary
        datetime completedAt
        bigint completedByUserId
    }

    TIMESHEET {
        bigint id
        bigint technicianId
        string technicianName
        date weekStartDate
        date weekEndDate
        string status
        string technicianSignatureText
        datetime submittedAt
        datetime approvedAt
    }

    TIMESHEET_ENTRY {
        bigint id
        bigint timesheetId
        bigint workOrderId
        date workDate
        string clientName
        string siteAddress
        decimal miles
        time onsiteStartTime
        time offsiteEndTime
        time breakStartTime
        time breakEndTime
        string comments
        boolean autoGenerated
    }
```

## Quick Glossary

- `SLA`: the promised timing expectation for work, such as due today or overdue
- `KPI`: a quick metric that helps teams see how operations are performing
- `JWT`: the token-based sign-in method used to keep API calls secure
- `Heatmap`: a visual way to show workload intensity across technicians
- `Completion Report`: the structured technician report submitted when a work order is finished
- `Timesheet Entry`: a weekly payroll row, usually generated from a completed work order
- `A3/WWTS Contract Completion Form`: a planned formal export generated from completed work order and completion report data

## Sprint Progress Snapshot

### Sprint 5

Focused on technician execution and completion:

- start work flow
- return-to-open flow
- structured field completion report
- signature capture
- reopen workflow
- backend workflow enforcement
- timeline completeness
- session timeout and refresh token support

### Sprint 6

Focused on dashboard foundations:

- upgraded summary endpoint
- recent activity endpoint
- analytics endpoint
- charts for status, priority, and completion trend
- cleaner operational dashboard layout

### Sprint 7

Focused on role-aware operational intelligence:

- SLA summary and detail blocks
- due-today and overdue visibility
- technician workload API
- workload card panel
- heatmap-ready workload presentation
- fuller role-based dashboard behavior

### Sprint 8 Direction

The next natural step is real-time collaboration and live operational updates.

Expected direction:

- WebSocket-based live dashboard refresh
- real-time work order state updates
- role-specific live notifications
- richer dispatcher visibility

Kafka remains a future scaling option for event-driven processing, but it is not required for the current stage of the platform.

### Sprint 9 — Production Hardening

Sprint 9 focuses on making the deployed system safer and easier to operate:

- frontend healthcheck fixes
- backup confirmation
- secret rotation readiness
- monitoring validation
- deployment documentation hardening

### Sprint 10 — Demo Readiness

Sprint 10 turns the production-style deployment into a portfolio-ready public demo:

- fictional Admin, Dispatcher, and Technician accounts with BCrypt-hashed passwords
- realistic technicians, work orders, overdue items, timeline events, and completion reports
- a visible demo-mode banner and one-click credentials on the login page
- an opt-in `prod,demo` backend profile that leaves ordinary production defaults unchanged
- a backup-first, confirmation-gated reset script for restoring clean demo data

See the [Sprint 10 demo-mode runbook](./docs/DEMO_MODE.md) for activation and reset instructions.

### Sprint 11 — SLA Intelligence

Sprint 11 separates dispatch, technician response, execution, and full-resolution clocks. The execution SLA begins when the technician starts travel or starts work through the compatibility path, then records near breach, breach, completion outcome, and technician performance.

The technician lifecycle is `OPEN -> ASSIGNED -> EN_ROUTE -> ARRIVED -> WORK_STARTED -> COMPLETED`. See the [Sprint 11 SLA execution map](./docs/SPRINT_11_SLA_INTELLIGENCE.md).

### Sprint 12 — Product Polish

Sprint 12 improves the product experience and reporting layer:

- Figma-inspired enterprise UI polish
- responsive application shell
- improved role dashboards
- operations reporting screen
- CSV and PDF export support
- updated GitHub documentation and screenshots

### Sprint 13 — Timesheet Automation And Payroll Reporting

Sprint 13 connects technician field execution to weekly payroll and contractor documentation:

- weekly timesheet module
- auto-added completed work orders
- manual mileage entry
- onsite and offsite timestamps
- break start and break end fields
- comments field
- technician signature
- admin review workflow
- weekly PDF and CSV export
- AOP logging and Swagger/OpenAPI documentation for the Timesheet API
- A3/WWTS contract completion form generation remains the next Sprint 13 follow-up

### Sprint 14 — Spring AI Assistant

Sprint 14 is the next roadmap step. The intended direction is to add an assistant layer that can explain the app, summarize field work, and support better operational decisions:

- chatbot UI
- backend Spring AI service
- app documentation Q&A
- work order insights
- technician assignment suggestions
- completion report summarization

## Visual Architecture Guide

The Mermaid overview above gives the quickest technical snapshot. The image-based diagrams below are the more presentation-ready visuals and are the best entry point for reviewers, stakeholders, and anyone who wants to understand the platform without reading implementation detail first.

If you are presenting the project live, these three visuals are the most useful sequence to show on screen.

### Current-State Architecture

![Current-state architecture](<mermaid-diagram (1).png>)

Today, A3 FSM runs as a practical monolithic full-stack application:

- Angular powers login, role-based navigation, dashboards, work order screens, reports, timesheets, and technician workflows
- Spring Boot handles authentication, business rules, workflow enforcement, dashboard aggregation, reporting, timesheet automation, and realtime event publishing
- PostgreSQL stores users, technicians, work orders, timeline events, completion reports, timesheets, timesheet entries, and attachment metadata

The current interaction model is intentionally simple:

- REST handles standard reads, writes, and business actions
- WebSocket handles live dashboard and notification updates
- one shared frontend serves admin, dispatch, and technician users with role-specific experiences

### Future-State Architecture

![Future-state architecture](<mermaid-diagram (3).png>)

This diagram represents a future evolution path rather than an immediate requirement. If the platform grows in scale or complexity, the backend can be separated into focused services such as:

- Auth Service
- Work Order Service
- SLA or Rules Service
- Report Service
- Timesheet and Payroll Service
- Dashboard or Analytics Service
- Notification or Realtime Service

In that future model:

- Kafka or another event bus can carry business events between backend services
- WebSocket still pushes live updates from backend services to browser clients
- the frontend experience can remain familiar even as the backend becomes more distributed

### Realtime Business Flow

![Assignment, completion, and SLA event flow](<mermaid-diagram (2).png>)

This flow shows how operational actions become live visibility across the platform:

- assignment updates can refresh workload views and recent activity immediately
- technician completion can update status, reporting, timesheets, and analytics without a full page reload
- SLA breaches can surface overdue pressure to admin and dispatch dashboards in real time
- submitted timesheets currently refresh through REST and are a good candidate for a future realtime review-queue topic

A simple way to think about it:

- REST records the business action
- backend logic validates and saves it
- realtime messaging broadcasts the update
- dashboards refresh without waiting for a manual reload

## Suggested Demo Story

If you are walking someone through the project, this is a strong and simple narrative:

1. Start with the current-state architecture to show the full system at a glance.
2. Move to the work order lifecycle to explain dispatch and technician execution.
3. Show the completion report lifecycle to explain how field outcomes become structured documentation.
4. Show the timesheet lifecycle to explain how completed work becomes payroll-ready weekly reporting.
5. Show the dashboard layers and realtime business flow to highlight visibility and operational value.
6. End with the future-state architecture to show where the platform can scale next.

## Audience Guide

If you are reviewing this project from different backgrounds, here is the easiest way to read it:

- non-technical stakeholders: focus on the business flow, lifecycle, dashboard sections, and sprint snapshot
- developers: move next into the backend and frontend READMEs for architecture, setup, and implementation detail
- reviewers, interviewers, and project assessors: use the diagrams to understand how the app maps real field operations into a traceable software workflow
- operations and payroll reviewers: focus on the completion report lifecycle, timesheet lifecycle, admin review, and export sections

## Running The Platform Locally

### Option 1: Run Repositories Separately

Use the backend and frontend README files for repo-specific commands and local development steps.

### Option 2: Run With Docker Compose

For day-to-day local development at the root workspace:

```bash
docker compose -f docker-compose.dev.yml --env-file .env up --build
```

Typical development endpoints:

- frontend: `http://localhost:4200`
- backend: `http://localhost:8080`
- pgAdmin: `http://localhost:5050`
- postgres host port: `5433`
- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`
- PostgreSQL exporter: `http://localhost:9187/metrics`

### Option 3: Run A Production-Shaped Stack Locally

```bash
docker compose -f docker-compose.prod.yml --env-file .env up --build -d
```

Default production-shaped exposure:

- frontend: `http://localhost`
- Grafana: `http://localhost:3000`

In the production compose file, the backend, database, Prometheus, and PostgreSQL exporter stay on the internal Docker network by default.

## Data And Environment Notes

- the backend can bootstrap demo data for containerized development
- development compose keeps admin bootstrap enabled for intentional local setup, while production compose keeps admin bootstrap and self-registration disabled
- the Docker setup can also be pointed at your real local Postgres data
- uploads are stored on a mounted volume so evidence files survive container restarts
- generated reports, planned contract completion forms, and weekly exports should be stored through controlled backend export paths or durable storage
- the root compose files expect both sibling repositories to exist with the exact folder names already used in this workspace

## Documentation Map

- [User Stories](./docs/USER_STORIES.md)
- [Business Rules](./docs/BUSINESS_RULES.md)
- [System Design](./docs/SYSTEM_DESIGN.md)
- [Sprint 10 Demo Mode](./docs/DEMO_MODE.md)
- [Sprint 10 Execution Map](./docs/SPRINT_10_DEMO_READINESS.md)
- [Sprint 11 SLA Intelligence](./docs/SPRINT_11_SLA_INTELLIGENCE.md)
- [Sprint 12 Product Polish](./docs/SPRINT_12_PRODUCT_POLISH.md)
- [Sprint 13 Timesheet Automation](./docs/SPRINT_13_TIMESHEET_AUTOMATION.md)
- [Backend README](./A3%20Field%20Service%20Management%20Backend/README.MD)
- [Frontend README](./A3%20Field%20Service%20Management%20Frontend/a3-fsm-frontend/README.md)

## Closing Summary

This platform is more than a task tracker. It is a field execution workflow shaped around how service teams actually work: assign, act, document, complete, review, approve, export, and improve.

The architecture is intentionally practical:

- strict enough to protect business rules
- simple enough to understand quickly
- flexible enough to grow into real-time operations, deeper analytics, payroll reporting, and role-based decision support
