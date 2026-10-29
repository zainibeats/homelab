# Homepage (OCI)

Homepage is an open-source, highly customizable dashboard that aggregates over 100 service APIs. This instance is the landing page for family and friends on NetBird: links to chat and watch parties, and live status for the game servers on the OCI host. It sits behind NetBird's Traefik and is reachable only by NetBird peers. The home instances are [Homepage (Admin)](../homepage-admin/README.md) and [Homepage (Public)](../homepage-public/README.md).

**Runs on:** the OCI host (must share the `services` network with netbird-server)

## Prerequisites

- [netbird-server](../../networking/netbird-server/README.md) and [netbird-client](../../networking/netbird-client/README.md) running, with `services` routed to peers and Traefik on it.
- A Cloudflare A record for `HOMEPAGE_HOST` → Traefik's IP on `services` (DNS only).

## Setup

```bash
cp .env.example .env
# fill in .env, then:
env -u HOSTNAME -u TZ docker compose up -d
```

Dashboard content lives in `config/` (`services.yaml`, `widgets.yaml`, `settings.yaml`, etc.), which is tracked in git. `HOMEPAGE_VAR_*` values from `.env` are substituted into those files as `{{HOMEPAGE_VAR_...}}`. Join passwords are shared in Element, never on the page.

## Configuration

- `HOMEPAGE_HOST` - Hostname for the dashboard; also passed as `HOMEPAGE_ALLOWED_HOSTS`.
- `HOMEPAGE_IP` - Static IP on `services`.
- `PUID`, `PGID` - Owner of `config/` in the clone. The entrypoint chowns `config/` to these, so they must match or the clone's files change owner.
- `ALLOWED_RANGES` - Who may connect through Traefik: NetBird peers and the routed network (masqueraded NetBird traffic).
- `TRAEFIK_ENTRYPOINT` - Traefik's HTTPS entrypoint (`websecure`).
- `TRAEFIK_CERTRESOLVER` - A DNS-01 resolver (`letsencrypt-dns`); the hostname resolves to a private IP.
- `HOMEPAGE_VAR_TITLE` - Page title.
- `HOMEPAGE_VAR_CHAT_HOST` - Element Web hostname ([Matrix](../../utilities/matrix/README.md) `CHAT_HOST`).
- `HOMEPAGE_VAR_NEKO_HOST` - [Neko (OCI)](../../utilities/neko-oci/README.md) hostname.
- `HOMEPAGE_VAR_MINECRAFT_HOST` - Address players join Minecraft with.
- `HOMEPAGE_VAR_MINECRAFT_IP`, `HOMEPAGE_VAR_PALWORLD_IP`, `HOMEPAGE_VAR_VALHEIM_IP` - Game servers' static IPs on `services`.

`TZ` (`America/Los_Angeles`) is set in the compose file.

## Routing & Ports

- `https://HOMEPAGE_HOST` - Through NetBird's Traefik, with the `homepage-oci-netbird-only` IP allowlist (`ALLOWED_RANGES`).
- No published ports. On `services`, the widgets reach the game servers directly: Minecraft `25565`, Valheim's Steam query port `2457/udp`, and a ping to Palworld.

## Data & Backups

- `./config` → `/app/config` - Dashboard config, tracked in git. `config/logs/` is gitignored.

## Troubleshooting

- Palworld shows only up/down: GameDig can query Palworld only through its admin REST API, which needs the admin password, so the card pings the container instead.
- A game shows offline while it's running: check the widget's port. Valheim answers queries on the game port + 1 (`2457`).
- `Host validation failed`: `HOMEPAGE_HOST` doesn't match the hostname in the browser.
