# Home Assistant

[Home Assistant](https://www.home-assistant.io/) is an open-source home automation platform that puts local control and privacy first. It tracks and controls the devices at home and automates them.

## Prerequisites

- A Zigbee coordinator or other radios reachable from the host (the container is privileged with host networking for device and mDNS discovery).

## Setup

```bash
docker compose up -d
```

Open `http://<host>:8123` and complete onboarding.

## Configuration

There is no `.env` file. `TZ` (`America/Los_Angeles`) is set in the compose file. Everything else is configured in the web UI or in YAML under `./config`.

## Routing & Ports

- `network_mode: host` - Home Assistant listens directly on the host at `8123`.
- The Application Server's Traefik routes it through the file-based config in `networking/traefik/config/dynamic/ubuntu-server*.yml`.

## Data & Backups

- `./config` → `/config` - All configuration, the database, and integrations (gitignored). Back it up regularly, or use the built-in backups under Settings > System > Backups.
- `/run/dbus` (read-only) - Bluetooth and host integrations.
- `/etc/localtime` (read-only) - Host timezone.

## Troubleshooting

- Devices not discovered: the container needs `network_mode: host` and `privileged: true`; don't remove them.
- See the [Home Assistant documentation](https://www.home-assistant.io/docs/).
