# SearXNG

SearXNG is a privacy-respecting, self-hosted metasearch engine that aggregates results from multiple search engines without tracking users. It is also the web-search backend for Open WebUI in the [AI stack](../../automation/ai-stack/README.md).

## Prerequisites

- The [Traefik](../../networking/traefik/README.md) stack running on the same host (it creates the external `traefik-proxy` network).
- The external `tmdb-net` network, shared with Open WebUI: `docker network create tmdb-net`.
- The NFS share mounted at `/mnt/nfs/apps/searxng/core-config`.

## Setup

```bash
cp .env.example .env
# set SEARXNG_SECRET (openssl rand -hex 16), then:
docker compose up -d
```

For Open WebUI, SearXNG must return JSON. Add this to `core-config/settings.yml` and restart:

```yaml
search:
  formats:
    - html
    - json
```

Then point Open WebUI's `SEARXNG_QUERY_URL` at `http://searxng-core:8080/search?q=<query>` (see the [AI stack](../../automation/ai-stack/README.md) configuration).

## Configuration

- `SEARXNG_SECRET` - Secret key used by SearXNG. Generate with `openssl rand -hex 16`.
- `DOMAIN` - Base domain for the Traefik routes (`search.${DOMAIN}`).
- `SUBDOMAIN` - LAN subdomain for the second route (`search.${SUBDOMAIN}.${DOMAIN}`).

Everything else is in `core-config/settings.yml`.

## Routing & Ports

- `search.${DOMAIN}` and `search.${SUBDOMAIN}.${DOMAIN}` - Web UI through Traefik (`websecure`, `cloudflare` resolver).
- `8086` → `8080` - Web UI on the host. Containers on `tmdb-net` use `searxng-core:8080`.
- Networks: `searxng-net` (internal, with Valkey), external `traefik-proxy`, external `tmdb-net`.

## Data & Backups

- `/mnt/nfs/apps/searxng/core-config` → `/etc/searxng/` - SearXNG configuration (`settings.yml`). Back this up.
- `core-data` volume - Search cache.
- `valkey-data` volume - Valkey (Redis-compatible) data; disposable.

## Troubleshooting

- `docker compose up` fails with "network tmdb-net declared as external, but could not be found": create it with `docker network create tmdb-net`.
- Open WebUI web search returns nothing: confirm `json` is in `search.formats` and that Open WebUI uses port `8080`, not `8086`.
