# Yopass

Yopass is a lightweight, self-hosted service for sharing secrets, passwords, and files. It encrypts data client-side, stores it temporarily in Memcached, and returns a one-time URL that expires automatically. Source: <https://github.com/jhaals/yopass>.

**Runs on:** Application Server

## Prerequisites

- The [Traefik](../../networking/traefik/README.md) stack running on the same host (it creates the external `traefik-proxy` network).

## Setup

```bash
cp .env.example .env
docker compose up -d
```

## Configuration

- `DOMAIN` - Base domain for the Traefik routes (`yopass.${DOMAIN}`).
- `SUBDOMAIN` - LAN subdomain for the second route (`yopass.${SUBDOMAIN}.${DOMAIN}`).

Yopass is started with `--memcached=memcached:11211 --port 80`; no other settings are needed for the default setup.

## Routing & Ports

- `yopass.${DOMAIN}` and `yopass.${SUBDOMAIN}.${DOMAIN}` - Web UI through Traefik (`websecure`, `cloudflare` resolver).
- `8889` → `80` - Web UI (`http://<host>:8889`).
- Memcached listens on `11211` on the internal `yopass-net` network only (not published).
- Networks: `yopass-net` (internal) and the external `traefik-proxy`.

## Data & Backups

None. Secrets live only in Memcached memory and are lost on restart, which is intended for temporary sharing. For persistent storage or other options, see the upstream project.

## Troubleshooting

- Links stop working after a restart: expected, Memcached holds secrets in memory only.
