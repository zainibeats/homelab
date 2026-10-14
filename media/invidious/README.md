# Invidious

Invidious is an open-source alternative frontend for YouTube. Unlike the official stack, this one routes **all** container traffic through a Gluetun VPN container.

| Service | Description |
|---------|-------------|
| Gluetun | VPN client; all outbound traffic routes through this container |
| Invidious | Main web interface |
| Invidious Companion | Handles video streaming via `youtubei.js` |
| PostgreSQL 14 | Database backend for Invidious |

**Runs on:** Application Server

## Prerequisites

- A VPN configuration compatible with Gluetun.
- `pwgen` for generating secret keys.
- The [Invidious repository](https://github.com/iv-org/invidious) cloned, with this stack's `docker-compose.yml` replacing the upstream one. The database container mounts `./config/sql` and `./docker/init-invidious-db.sh` from it:

  ```bash
  git clone https://github.com/iv-org/invidious.git
  cp docker-compose.yml .env.example invidious/
  ```

## Setup

```bash
cp .env.example .env
# fill in .env (pwgen 16 1 for each key), then:
docker compose up -d
```

Open `http://<host>:3080`.

## Configuration

| Variable | Description |
|----------|-------------|
| `TZ` | Timezone (e.g. `America/Los_Angeles`) |
| `VPN_SERVICE_PROVIDER` | VPN provider (e.g. `protonvpn`, `mullvad`) |
| `VPN_TYPE` | VPN protocol (`wireguard`) |
| `WIREGUARD_PUBLIC_KEY` | WireGuard public key from your VPN config |
| `WIREGUARD_PRIVATE_KEY` | WireGuard private key from your VPN config |
| `SERVER_COUNTRIES` | Comma-separated list of countries (e.g. `"United States"`) |
| `POSTGRES_USER` | PostgreSQL username |
| `POSTGRES_PASSWORD` | PostgreSQL password |
| `HMAC_KEY` | Secret key for Invidious (`pwgen 16 1`) |
| `COMPANION_KEY` | Shared secret between Invidious and Companion (`pwgen 16 1`) |

## Routing & Ports

- `invidious`, `companion`, and `invidious-db` use `network_mode: "service:gluetun"`: they share Gluetun's network stack and have no network access of their own.
- `3080` → `3000` - The only published port, on Gluetun (Invidious web UI).
- Gluetun has a static IP (`172.172.0.2`) on `invidious-net` (`172.172.0.0/24`).
- Companion is reached at `http://127.0.0.1:8282/companion` (loopback inside the shared namespace).

## Data & Backups

- `postgresdata` volume - Invidious database (accounts, subscriptions). Back up with `pg_dump`.
- `companioncache` volume - Companion's `youtubei.js` cache; disposable.
- `./gluetun` - Gluetun data.

## Troubleshooting

Check that traffic leaves through the VPN:

```bash
docker exec -it gluetun-invidious sh
wget https://ipinfo.io
cat index.html
```

The returned IP should belong to your VPN provider, not your home ISP.

Docs: [Invidious](https://docs.invidious.io/), [Invidious Companion](https://github.com/iv-org/invidious-companion), [Gluetun](https://github.com/qdm12/gluetun/wiki).
