# Invidious

Invidiousis an open-source alternative frontend for YouTube

## Components

| Service | Description |
|---------|-------------|
| Gluetun | VPN client — all outbound traffic routes through this container |
| Invidious | Main web interface |
| Invidious Companion | Handles video streaming via `youtubei.js` |
| PostgreSQL 14 | Database backend for Invidious |

## How This Differs from the Official Stack

The official Invidious docker-compose does not include a VPN. This setup routes **all container traffic** through a Gluetun VPN container:

- `invidious`, `companion`, and `invidious-db` all use `network_mode: "service:gluetun"` — they share Gluetun's network stack and have no direct network access of their own
- The only exposed port is on the Gluetun container: `3080` (mapped to Invidious's internal port `3000`)
- A dedicated Docker network (`invidious-net`, subnet `172.172.0.0/24`) is used with a static IP for Gluetun (`172.172.0.2`)
- The companion service is included and wired to Invidious via `http://127.0.0.1:8282/companion` (loopback within the shared network namespace)

## Prerequisites

1. Docker and Docker Compose installed
2. A VPN configuration compatible with Gluetun
3. `pwgen` installed for generating secret keys
4. The [Invidious repository](https://github.com/iv-org/invidious) cloned into a directory of your choosing. The database container mounts `./config/sql` and `./docker/init-invidious-db.sh` directly from it:

```bash
git clone https://github.com/iv-org/invidious.git
```

> **Note:** Replace the `docker-compose.yml` with [this one](./docker-compose.yml).

## Setup

### 1. Configure Environment Variables

Copy the example file and fill in your values:

```bash
cp .env.example .env
```

| Variable | Description |
|----------|-------------|
| `TZ` | Your timezone (e.g. `America/Los_Angeles`) |
| `VPN_SERVICE_PROVIDER` | Your VPN provider (e.g. `protonvpn`, `mullvad`) |
| `VPN_TYPE` | VPN protocol (`wireguard`) |
| `WIREGUARD_PUBLIC_KEY` | WireGuard public key from your VPN config |
| `WIREGUARD_PRIVATE_KEY` | WireGuard private key from your VPN config |
| `SERVER_COUNTRIES` | Comma-separated list of countries (e.g. `"United States"`) |
| `POSTGRES_USER` | PostgreSQL username |
| `POSTGRES_PASSWORD` | PostgreSQL password |
| `HMAC_KEY` | Secret key for Invidious (generate with `pwgen 16 1`) |
| `COMPANION_KEY` | Shared secret between Invidious and Companion (generate with `pwgen 16 1`) |

### 2. Start the Stack

```bash
docker compose up -d
```

### 3. Access the Web Interface

```
http://<your-server-ip>:3080
```

## Verify VPN is Working

```bash
docker exec -it gluetun-invidious sh
wget https://ipinfo.io
cat index.html
```

The returned IP should belong to your VPN provider, not your home ISP.

## Official Documentation

- [Invidious documentation](https://docs.invidious.io/)
- [Invidious Companion](https://github.com/iv-org/invidious-companion)
- [Gluetun documentation](https://github.com/qdm12/gluetun/wiki)
