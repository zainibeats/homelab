# Monitoring (Home)

The on-prem monitoring stack: Prometheus for metrics, Loki and Promtail for logs, Grafana for dashboards, Node Exporter for host metrics, and cAdvisor (with Redis) for container metrics. It is based on [brandonleegit/OpenSourceMonitoring](https://github.com/brandonleegit/OpenSourceMonitoring). The OCI stack is in [monitoring-oci](../monitoring-oci/README.md).

**Runs on:** Raspberry Pi

## Prerequisites

- The [Traefik](../../networking/traefik/README.md) stack running on the same host (it creates the external `traefik-proxy` network).
- Host directories for Prometheus and Grafana data, owned by UID/GID `1000`:

  ```bash
  mkdir -p ~/promgrafnode/prometheus
  mkdir -p ~/promgrafnode/grafana/provisioning/datasources
  ```

## Setup

The compose file is tracked as `docker-compose.example.yml`; the live `docker-compose.yml` is gitignored so it can be adjusted per host. Keep `name: monitoring` as its first line: the volume and network names depend on it, and a copy made before the name was pinned won't have it.

```bash
cp docker-compose.example.yml docker-compose.yml
cp .env.example .env
cp prometheus/prometheus.yml ~/promgrafnode/prometheus/prometheus.yml
docker compose up -d
```

On every other machine to be monitored, run only Node Exporter with the standalone [`node-exporter/docker-compose.yml`](./node-exporter/docker-compose.yml) (`docker compose up -d` in that folder), then add the machine as a target in `prometheus.yml`.

Grafana provisions only the Loki datasource (as the default) through its entrypoint. Add Prometheus (`http://prometheus:9090`) in Grafana under **Connections → Data sources**.

## Configuration

- `DOMAIN` - Base domain for the Grafana Traefik route (`grafana.${DOMAIN}`).

Other settings are fixed in the compose file:

- `prometheus` and `grafana` run as user `1000`. Change the `user` directive if the host directories belong to another user.
- Grafana has anonymous access enabled with the **Admin** role (`GF_AUTH_ANONYMOUS_ENABLED=true`, `GF_AUTH_ANONYMOUS_ORG_ROLE=Admin`), so anyone who can reach it has full access. Keep it on trusted networks.
- Prometheus targets are in `~/promgrafnode/prometheus/prometheus.yml` (sample in [`prometheus/prometheus.yml`](./prometheus/prometheus.yml)).

## Routing & Ports

- `grafana.${DOMAIN}` - Grafana through Traefik (`websecure`, `cloudflare` resolver).
- `3000` - Grafana.
- `9090` - Prometheus.
- `9100` - Node Exporter metrics (`/metrics`).
- `3100` - Loki.
- `8080` - cAdvisor.
- `6379` - Redis (used by cAdvisor).
- Networks: `monitoring` (internal bridge) and `traefik-proxy` (external, Grafana only).

## Data & Backups

- `~/promgrafnode/prometheus` - Prometheus TSDB and config. Back up `prometheus.yml`; the TSDB is optional.
- `~/promgrafnode/grafana` - Grafana database (dashboards, users). Back this up.
- `~/promgrafnode/grafana/provisioning/datasources` - Datasource provisioning files.
- Loki and Redis keep data inside their containers (no volumes); it is lost when they are recreated.
- Read-only host mounts: `/proc`, `/sys`, `/` (Node Exporter, cAdvisor), `/var/log` (Promtail), `/var/lib/docker` (cAdvisor).

## Troubleshooting

- Prometheus or Grafana fails with permission errors: the `~/promgrafnode` directories must be writable by UID `1000`.
- No Prometheus data in Grafana: the Prometheus datasource isn't provisioned automatically; add it (see Setup).
