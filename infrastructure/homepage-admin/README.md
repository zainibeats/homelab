# Homepage (Admin)

Homepage is an open-source, highly customizable dashboard that aggregates over 100 service APIs. This is the administrator instance, with links and widgets for internal hosts and services; the public instance is [Homepage (Public)](../homepage-public/README.md).

## Prerequisites

- The [Traefik](../../networking/traefik/README.md) stack (it creates the external `traefik-proxy` network).

## Setup

```bash
cp .env.example .env
# fill in .env, then:
docker compose up -d
```

Dashboard content lives in `config/` (`services.yaml`, `widgets.yaml`, `bookmarks.yaml`, `settings.yaml`, etc.), which is tracked in git. `HOMEPAGE_VAR_*` values from `.env` are substituted into those files as `{{HOMEPAGE_VAR_...}}`.

## Configuration

- `HOMEPAGE_ALLOWED_HOSTS` - Hosts (with port if needed) allowed to load the dashboard, e.g. `172.20.20.30:3330`. Required by Homepage.
- `HOMEPAGE_VAR_DOMAIN` - Domain used in service links.
- `HOMEPAGE_VAR_APP_HOST` - Application Server IP.
- `HOMEPAGE_VAR_STORAGE_HOST` - NAS IP.
- `HOMEPAGE_VAR_PROXMOX_HOST` - GPU Compute Node (Proxmox) IP.
- `HOMEPAGE_VAR_MONITOR_HOST` - Monitoring host (Raspberry Pi) IP.
- `HOMEPAGE_VAR_IPMI_HOST` - IPMI interface IP.
- `HOMEPAGE_VAR_ZIGBEE_HOST` - Zigbee coordinator IP.
- `HOMEPAGE_VAR_ROUTER_HOST` - Router IP.
- `HOMEPAGE_VAR_SWITCH_HOST` - Switch IP.
- `HOMEPAGE_VAR_QBIT_USER` - qBittorrent username (qBittorrent widget).
- `HOMEPAGE_VAR_QBIT_PWD` - qBittorrent password (qBittorrent widget).
- `DOMAIN` - Base domain for the Traefik route (`admin.${DOMAIN}`).

`PUID`/`PGID` (`1000`) and `TZ` (`America/Los_Angeles`) are set in the compose file.

## Routing & Ports

- `admin.${DOMAIN}` - Dashboard through Traefik (`websecure`, `cloudflare` resolver).
- `3330` → `3000` - Dashboard (`http://<host>:3330`).
- Joins the external `traefik-proxy` network.

## Data & Backups

- `./config` → `/app/config` - All Homepage YAML, CSS, and JS configuration (tracked in git).
- `.env` - Holds credentials; back it up.

## Troubleshooting

- "Host validation failed": add the URL you're using (with port) to `HOMEPAGE_ALLOWED_HOSTS`.
- If remote monitoring reports a 'status not available' error, ensure that the necessary TCP ports are allowed through the firewall (UFW).
