# IT Tools

A collection of handy online tools for developers and IT professionals: encoders/decoders, formatters, converters, generators, and more. Everything runs in the browser, so no data leaves your network.

**Runs on:** Application Server

## Prerequisites

- The [Traefik](../../networking/traefik/README.md) stack running on the same host (it creates the external `traefik-proxy` network).

## Setup

```bash
cp .env.example .env
docker compose up -d
```

All tools are available immediately, with no login.

## Configuration

The compose file loads `.env` (`env_file`), so the file must exist even though the app itself needs no settings.

- `DOMAIN` - Base domain for the Traefik routes (`it-tools.${DOMAIN}`).
- `SUBDOMAIN` - LAN subdomain for the second route (`it-tools.${SUBDOMAIN}.${DOMAIN}`).

## Routing & Ports

- `it-tools.${DOMAIN}` and `it-tools.${SUBDOMAIN}.${DOMAIN}` - Web UI through Traefik (`websecure`, `cloudflare` resolver).
- `8881` → `80` - Web UI (`http://<host>:8881`).
- Joins the external `traefik-proxy` network.

## Data & Backups

None. The app is stateless.

## Troubleshooting

- `docker compose up` fails with "env file not found": run `cp .env.example .env`.
