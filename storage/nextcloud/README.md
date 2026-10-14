# Nextcloud

Nextcloud is a self-hosted file hosting suite, similar to Dropbox or Google Drive, with optional office integration (Collabora Online, OnlyOffice). This stack runs `nextcloud:latest` with MariaDB 10.6; user files live on the NAS over NFS.

**Runs on:** Application Server

## Prerequisites

- The [Traefik](../../networking/traefik/README.md) stack running on the same host (it creates the external `traefik-proxy` network).
- The NFS share mounted at `/mnt/nfs/apps/nextcloud`, owned by `1005:1005`:

  ```bash
  sudo mkdir -p /mnt/nfs/apps/nextcloud
  # /etc/fstab (replace the server and export path):
  # 192.168.1.100:/mnt/pool/nextcloud /mnt/nfs/apps/nextcloud nfs defaults 0 0
  sudo mount -a
  sudo chown -R 1005:1005 /mnt/nfs/apps/nextcloud
  ```

## Setup

```bash
cp .env.example .env
# set the passwords and PUID/PGID, then:
docker compose up -d
```

Open `http://<host>:8080` and finish the setup wizard with database host `db`, database `nextcloud`, user `nextcloud`, and the `MYSQL_PASSWORD` from `.env` (the database name and user are fixed in the compose file).

Add each hostname you use to the trusted domains:

```bash
docker exec --user www-data nextcloud php occ config:system:set trusted_domains 3 --value=nextcloud.domain.tld
```

## Configuration

- `MYSQL_ROOT_PASSWORD` - MariaDB root password.
- `MYSQL_PASSWORD` - Password for the `nextcloud` database user (used by both containers).
- `PUID` - User ID passed to the app container. Set it to the NFS share owner (`1005` in my setup; the example has `1000`).
- `PGID` - Group ID passed to the app container (`1005` in my setup).
- `DOMAIN` - Base domain for the Traefik routes (`nextcloud.${DOMAIN}`).
- `SUBDOMAIN` - LAN subdomain for the second route (`nextcloud.${SUBDOMAIN}.${DOMAIN}`).

## Routing & Ports

- `nextcloud.${DOMAIN}` and `nextcloud.${SUBDOMAIN}.${DOMAIN}` - Web UI through Traefik (`websecure`, `cloudflare` resolver).
- `8080` → `80` - Web UI on the host.
- Networks: `nextcloud-net` (internal, with MariaDB) and the external `traefik-proxy`.

## Data & Backups

- `/mnt/nfs/apps/nextcloud` → `/var/www/html/data` - User files (NFS). Covered by the NAS backup.
- `nextcloud` volume → `/var/www/html` - Nextcloud code, apps, and `config/config.php`. Back up `config.php`.
- `db` volume - MariaDB data. Back up with `mysqldump`.

## Troubleshooting

- "Access through untrusted domain": add the hostname with the `occ` command in Setup.
- Permission errors in the data directory: the official image runs PHP as `www-data`, so the NFS share must let that user write (check the share's owner and mapping on the NAS).
