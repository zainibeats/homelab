# Immich

Immich is a high-performance, self-hosted photo and video backup solution with Google Photos-like features. Media lives on the NAS over SMB; the database stays on local storage.

**Runs on:** Application Server

## Prerequisites

- The [Traefik](../../networking/traefik/README.md) stack running on the same host (it creates the external `traefik-proxy` network).
- The NAS SMB share mounted at `/mnt/truenas_data/immich`, owned by UID/GID `1000`:

  ```bash
  sudo mkdir -p /mnt/truenas_data/immich
  # /etc/fstab (replace the server, share, and credentials file):
  # //192.168.1.100/ImmichData /mnt/truenas_data/immich cifs credentials=/etc/smb_credentials,uid=1000,gid=1000,iocharset=utf8,nofail 0 0
  sudo mount -a
  sudo mkdir -p /mnt/truenas_data/immich/library
  sudo chown -R 1000:1000 /mnt/truenas_data/immich
  ```

## Setup

```bash
cp .env.example .env
# set TZ and DB_PASSWORD, then:
docker compose up -d
```

Open the web UI, create the admin account, and start uploading.

## Configuration

- `DOMAIN` - Base domain for the Traefik routes (`immich.${DOMAIN}`).
- `SUBDOMAIN` - LAN subdomain for the second route (`immich.${SUBDOMAIN}.${DOMAIN}`).
- `UPLOAD_LOCATION` - Where media is stored: the SMB mount, `/mnt/truenas_data/immich/library`.
- `DB_DATA_LOCATION` - Postgres data directory, `./postgres`. Must be local storage; network shares aren't supported for the database.
- `TZ` - Timezone, e.g. `America/Los_Angeles`.
- `IMMICH_VERSION` - Image tag, `release` or a pinned version like `v1.71.0`.
- `DB_PASSWORD` - Postgres password. Use only `A-Za-z0-9`.
- `DB_USERNAME` - Postgres user (`postgres`); no need to change.
- `DB_DATABASE_NAME` - Postgres database (`immich`); no need to change.

See the [Immich environment variables](https://immich.app/docs/install/environment-variables) for more. Hardware acceleration is off; the compose file has commented `extends` blocks for it.

## Routing & Ports

- `immich.${DOMAIN}` and `immich.${SUBDOMAIN}.${DOMAIN}` - Web UI through Traefik (`websecure`, `cloudflare` resolver).
- `2283` - Web UI and API (`http://<host>:2283`).
- Networks: `immich-net` (internal) and the external `traefik-proxy` (server only).

## Data & Backups

- `/mnt/truenas_data/immich/library` - Media files (SMB share). Covered by the NAS backup.
- `./postgres` - Database (local). Back it up regularly:

  ```bash
  docker exec immich_postgres pg_dump -U postgres immich > immich_backup_$(date +%Y%m%d).sql
  ```

- `model-cache` volume - Machine learning models; re-downloaded if lost.

## Troubleshooting

Permission errors on the SMB share:

```bash
ls -la /mnt/truenas_data/immich
sudo chown -R 1000:1000 /mnt/truenas_data/immich
```

See the [Immich documentation](https://immich.app/docs/) for more.
