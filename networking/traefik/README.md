# Traefik

Traefik is the edge router and reverse proxy for the homelab. It terminates TLS with Let's Encrypt certificates issued through the Cloudflare DNS challenge, routes Docker services by their labels, and routes services on other hosts through file-based dynamic configuration. A `cloudflared` container in the same stack connects a Cloudflare Tunnel to the `traefik-proxy` network.

**Runs on:** Application Server and Raspberry Pi (OCI and AWS use the Traefik bundled in [netbird-server](../netbird-server/README.md) and [ollama-aws-hybrid](../../automation/ollama-aws-hybrid/README.md))

## Prerequisites

- A Cloudflare-managed domain and an API token with `Zone:DNS:Edit` permission for it.
- A Cloudflare Tunnel token, if you use the `cloudflared` service.
- Ports 80 and 443 free on the host.

## Setup

```shell
cp .env.example .env
cp config/traefik.example.yml config/traefik.yml
# Copy only the dynamic files this host needs, e.g.:
cp config/dynamic/pi5.example.yml config/dynamic/pi5.yml
mkdir -p letsencrypt && touch letsencrypt/acme.json && chmod 600 letsencrypt/acme.json
docker compose up -d
```

Edit `config/traefik.yml` and set `certificatesResolvers.cloudflare.acme.email` to your address. The live `config/traefik.yml` and `config/dynamic/*.yml` files are gitignored; only the `.example.yml` files are tracked.

Dynamic configuration examples:

- `pi5.example.yml` - Homepage, Grafana, and Uptime Kuma on the Raspberry Pi.
- `truenas.example.yml` - TrueNAS web UI.
- `ubuntu-server.example.yml`, `ubuntu-server-host.example.yml`, `ubuntu-server-lan.example.yml` - qBittorrent, Prowlarr, Jellyfin, Home Assistant, and Neko on the Application Server (public, host-network, and LAN-only variants).

## Configuration

- `CF_DNS_API_TOKEN` - Cloudflare API token used for the DNS challenge.
- `CF_API_EMAIL` - Cloudflare account email. Only needed with a global API key (`CF_API_KEY`); unused when `CF_DNS_API_TOKEN` is set.
- `DOMAIN` - Base domain; the dashboard is served at `traefik.${DOMAIN}`.
- `TUNNEL_TOKEN` - Cloudflare Tunnel token for the `cloudflared` service.

Static configuration lives in `config/traefik.yml`: entrypoints `web` (`:80`, redirects to HTTPS) and `websecure` (`:443`), the Docker provider (`exposedByDefault: false`, network `traefik-proxy`), the file provider (`/etc/traefik/dynamic`), and the `cloudflare` certificate resolver.

## Routing & Ports

- `80` - HTTP, redirected to HTTPS.
- `443` - HTTPS.
- `traefik.${DOMAIN}` (`/api`, `/dashboard`) - Traefik dashboard.
- This stack creates the `traefik-proxy` network. Other stacks join it as an external network and opt in with `traefik.enable=true`.

## Data & Backups

- `./letsencrypt/acme.json` - Issued certificates (mode `600`, gitignored). Back it up to avoid re-issuing certificates.
- `./config/traefik.yml`, `./config/dynamic/` - Live configuration (gitignored); back these up.
- `/var/run/docker.sock` (read-only) - Docker provider.

## Troubleshooting

- Certificates not issued: check `docker logs traefik` for DNS challenge errors and confirm the token's zone permissions. `acme.json` must be mode `600`, or Traefik refuses to use it.
- A service isn't routed: confirm it is on the `traefik-proxy` network and has `traefik.enable=true`.
