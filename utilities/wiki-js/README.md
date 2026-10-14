# Wiki.js

Wiki.js is a self-hosted documentation and knowledge base platform. This stack runs Wiki.js 2 with PostgreSQL 15 and exposes the web interface through Traefik.

**Runs on:** Application Server

## Prerequisites

- The [Traefik](../../networking/traefik/README.md) stack running on the same host (it creates the external `traefik-proxy` network).

## Setup

```bash
cp .env.example .env
# set real passwords in .env, then:
docker compose up -d
```

Open the web UI and complete the setup wizard (admin account and site URL).

## Configuration

PostgreSQL:

- `POSTGRES_DB` - Database name.
- `POSTGRES_USER` - Database user.
- `POSTGRES_PASSWORD` - Database password.

Wiki.js (must match the PostgreSQL values):

- `DB_NAME` - Must equal `POSTGRES_DB`.
- `DB_USER` - Must equal `POSTGRES_USER`.
- `DB_PASS` - Must equal `POSTGRES_PASSWORD`.
- `TZ` - Timezone, e.g. `America/Los_Angeles`.

Traefik:

- `DOMAIN` - Base domain for the Traefik routes (`wiki.${DOMAIN}`).
- `SUBDOMAIN` - LAN subdomain for the second route (`wiki.${SUBDOMAIN}.${DOMAIN}`).

## Routing & Ports

- `wiki.${DOMAIN}` and `wiki.${SUBDOMAIN}.${DOMAIN}` - Web UI through Traefik (`websecure`, `cloudflare` resolver) on container port `3000`.
- `8839` → `3000` - Web UI on the host.
- Joins the external `traefik-proxy` network.

## Data & Backups

- `db-data` volume → `/var/lib/postgresql/data` - All wiki content lives in PostgreSQL. Back up with `pg_dump` or configure Wiki.js Git storage.

## Troubleshooting

Git storage: SSH did not work with a custom SSH port, even after allowing the Docker network to reach it with a URL like:

```text
ssh://user@server:port/path/to/git/dir
```

HTTP did not work with an account password either. A personal access token worked when the Git URL used the machine's local IP address, for example:

```text
http://192.168.1.100:3331/path/to/git/repo
```
