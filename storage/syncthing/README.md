# Syncthing

[Syncthing](https://syncthing.net/) continuously synchronizes files between two or more devices in real time, without a third party. It keeps the Obsidian vault and other folders in sync between the NAS and the desktop.

**Runs on:** NAS and Desktop

## Prerequisites

- A host directory for synced data (`SYNCTHING_DATA`), writable by UID/GID `1000`.

## Setup

```bash
cp .env.example .env
# set HOSTNAME and SYNCTHING_DATA, then:
docker compose up -d
```

Open the web GUI at `http://<host>:8384`, set a GUI password, and add the other device by its device ID.

## Configuration

- `HOSTNAME` - Container hostname, used as the default device name.
- `SYNCTHING_DATA` - Host path mounted at `/var/syncthing` (synced folders).

`PUID`/`PGID` (`1000`) are set in the compose file.

## Routing & Ports

The container uses `network_mode: host`, so it listens directly on the host:

- `8384/tcp` - Web GUI (HTTP).
- `22000/tcp` - Sync protocol (TCP).
- `22000/udp` - Sync protocol (QUIC).
- `21027/udp` - Local discovery.

Allow `22000/tcp`, `22000/udp` and `21027/udp` through the host firewall. See the [Syncthing firewall docs](https://docs.syncthing.net/users/firewall.html).

## Data & Backups

- `${SYNCTHING_DATA}` → `/var/syncthing` - Synced folders.
- `./config` → `/var/syncthing/config` - Device keys, certificate, and folder settings (gitignored). Back this up; losing it changes the device ID. The separate mount keeps the config local even when `SYNCTHING_DATA` is on an external drive.

## Troubleshooting

- The health check calls `127.0.0.1:8384/rest/noauth/health`; if the container shows unhealthy, check that the GUI is listening on port `8384`.
- Devices don't connect: confirm ports `22000` and `21027/udp` are open on both hosts.
- See the [Syncthing documentation](https://docs.syncthing.net/).
