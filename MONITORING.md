# A3 FSM Monitoring

Sprint 9 adds a Prometheus and Grafana observability stack for the Spring Boot backend, PostgreSQL, SLA monitoring, realtime stability, and workload visibility.

## Services

These URLs apply to the development stack started with `docker-compose.dev.yml`.

- Backend metrics: `http://localhost:8080/actuator/prometheus`
- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`
- PostgreSQL exporter: `http://localhost:9187/metrics`

In `docker-compose.prod.yml`, Grafana remains published on `http://localhost:3000`, while Prometheus and the PostgreSQL exporter stay internal to the Docker network by default.

Grafana is provisioned automatically with the `A3 FSM Operational Overview` dashboard and a Prometheus datasource.

## Start Dev Monitoring

```sh
docker compose -f docker-compose.dev.yml --env-file .env up --build -d
```

Default Grafana credentials come from:

```text
GRAFANA_ADMIN_USER
GRAFANA_ADMIN_PASSWORD
```

Set both in `.env`.

## What Is Monitored

- SLA visibility: overdue work orders, due-today work orders, SLA monitor runs, SLA breaches published.
- Workload insight: work orders by status, assigned active work, unassigned active work, technician count.
- API performance: request throughput and p95 latency from Spring MVC metrics.
- JVM health: heap usage, process CPU, system CPU, live threads, daemon threads.
- Backend DB pool: Hikari active and pending connections.
- Database health: PostgreSQL exporter status, active DB connections, commits/sec, rollbacks/sec.
- Realtime stability: dashboard, alert, and user notification event throughput.

## Prometheus Targets

In Prometheus, open `Status -> Targets`. You should see:

- `a3-fsm-backend`
- `a3-fsm-postgres`
- `prometheus`

All should be `UP`.

## Useful PromQL

```promql
up{job="a3-fsm-backend"}
a3_fsm_work_orders_overdue
sum(rate(http_server_requests_seconds_count{job="a3-fsm-backend",uri!~"/actuator.*"}[5m]))
histogram_quantile(0.95, sum(rate(http_server_requests_seconds_bucket{job="a3-fsm-backend",uri!~"/actuator.*"}[5m])) by (le, uri)) * 1000
sum(rate(a3_fsm_realtime_events_published_total[5m])) by (destination)
hikaricp_connections_active{job="a3-fsm-backend"}
pg_stat_database_numbackends{job="a3-fsm-postgres",datname!~"template.*|postgres"}
```

## Future Sprint Hooks

For Sprint 10 notifications, add counters and timers around notification enqueue, delivery, failure, and retry code. Those will naturally appear in Prometheus and can be added to the same Grafana dashboard.

For mobile usage, the existing HTTP metrics already expose request rate and latency by URI. Additional tags or dedicated counters can be added for mobile-only endpoints when those routes exist.

For Kafka or event streaming, add Kafka exporter and Micrometer Kafka/client metrics to monitor consumer lag, publish throughput, consumer throughput, retry counts, and dead-letter counts.
