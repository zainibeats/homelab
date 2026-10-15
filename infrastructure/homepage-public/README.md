# Homepage (Public)

Homepage is an open-source, highly customizable dashboard that aggregates over 100 service APIs. This is the public instance; the admin instance is [Homepage (Admin)](../homepage-admin/README.md).

<img src="https://assets.czaini.net/images/homepage-clip.jpg" height="75%" width="75%" />

## Prerequisites

- The [Traefik](../../networking/traefik/README.md) stack (it creates the external `traefik-proxy` network).
- An [OpenWeatherMap](https://openweathermap.org/api) API key for the weather widget.

## Setup

```bash
cp .env.example .env
# fill in .env, then:
docker compose up -d
```

Dashboard content lives in `config/` (`services.yaml`, `widgets.yaml`, `bookmarks.yaml`, `settings.yaml`, etc.), which is tracked in git. `HOMEPAGE_VAR_*` values from `.env` are substituted into those files as `{{HOMEPAGE_VAR_...}}`.

## Configuration

- `HOMEPAGE_ALLOWED_HOSTS` - Hosts (with port if needed) allowed to load the dashboard, e.g. `172.23.20.30:7575,homepage.domain.tld`. Required by Homepage.
- `HOMEPAGE_VAR_OWM_KEY` - OpenWeatherMap API key (weather widget).
- `HOMEPAGE_VAR_OWM_LABEL` - Weather widget label.
- `HOMEPAGE_VAR_OWM_LAT` - Weather latitude.
- `HOMEPAGE_VAR_OWM_LONG` - Weather longitude.
- `HOMEPAGE_VAR_DOMAIN` - Domain used in service links.
- `HOMEPAGE_VAR_APP_HOST` - Application Server IP used in service links.
- `DOMAIN` - Base domain for the Traefik routes.
- `SUBDOMAIN` - LAN subdomain for the second route.

`PUID`/`PGID` (`1000`) and `TZ` (`America/Los_Angeles`) are set in the compose file.

## Routing & Ports

- `homepage.${DOMAIN}` and `homepage.${SUBDOMAIN}.${DOMAIN}` - Dashboard through Traefik (`websecure`, `cloudflare` resolver).
- `7575` → `3000` - Dashboard (`http://<host>:7575`).
- Joins the external `traefik-proxy` network.

## Data & Backups

- `./config` → `/app/config` - All Homepage YAML, CSS, and JS configuration (tracked in git).
- `.env` - Holds the API key; back it up.

## Troubleshooting

- "Host validation failed": add the URL you're using (with port) to `HOMEPAGE_ALLOWED_HOSTS`.
- If remote monitoring reports a 'status not available' error, ensure that the necessary TCP ports are allowed through the firewall (UFW).
