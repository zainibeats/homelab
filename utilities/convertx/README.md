# ConvertX

ConvertX is a self-hosted file conversion service with a web interface for converting between many file formats.

**Runs on:** Application Server

## Prerequisites

- The [Traefik](../../networking/traefik/README.md) stack running on the same host (it creates the external `traefik-proxy` network).

## Setup

```bash
cp .env.example .env
# set JWT_SECRET (e.g. openssl rand -hex 32), then:
docker compose up -d
```

Open the web UI and create the first account.

## Configuration

- `JWT_SECRET` - Secret used to sign login tokens. Use a long random value.
- `DOMAIN` - Base domain for the Traefik routes (`convertx.${DOMAIN}`).
- `SUBDOMAIN` - LAN subdomain for the second route (`convertx.${SUBDOMAIN}.${DOMAIN}`).

## Routing & Ports

- `convertx.${DOMAIN}` and `convertx.${SUBDOMAIN}.${DOMAIN}` - Web UI through Traefik (`websecure`, `cloudflare` resolver).
- `3000` - Web interface and API.
- Joins the external `traefik-proxy` network.

## Data & Backups

- `./data` → `/app/data` - Accounts, uploaded and converted files. Back up only if you want to keep accounts and history.

## Troubleshooting

- Logged out after every restart: `JWT_SECRET` is empty or changed; set a fixed value in `.env`.
