# Uptime Kuma

Uptime Kuma is a lightweight, self-hosted uptime monitor. It checks HTTP, TCP, DNS, and ping endpoints, and monitors Docker containers through the Docker socket.

## Prerequisites

- The [Traefik](../../networking/traefik/README.md) stack running on the same host (it creates the external `traefik-proxy` network).

## Setup

```bash
cp .env.example .env
docker compose up -d
```

Open the web UI and create the admin account on first visit.

## Configuration

- `DOMAIN` - Base domain for the Traefik route (`uptime.${DOMAIN}`).

Monitors, notifications, and status pages are configured in the web UI.

## Routing & Ports

- `uptime.${DOMAIN}` - Web UI through Traefik (`websecure`, `cloudflare` resolver).
- `3001` - Web UI (`http://<host>:3001`).
- Joins the external `traefik-proxy` network.
- Push monitors and status badges use the `/api/push/...` and `/api/badge/...` endpoints; Prometheus metrics are at `/metrics`.

## Data & Backups

- `./data` → `/app/data` - Monitors, settings, and history (SQLite). Back this up.
- `/var/run/docker.sock` (read-only) - Docker container monitoring.

## Troubleshooting

- Docker monitors fail: confirm the socket mount and that the container can read `/var/run/docker.sock`.
