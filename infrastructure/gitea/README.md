# Gitea

Gitea is a lightweight, self-hosted Git service with a web interface, SSH, REST API, package registry, and CI/CD. This stack runs `docker.gitea.com/gitea:1.25.4` with a MySQL 8 database.

**Runs on:** Application Server

## Prerequisites

- The [Traefik](../../networking/traefik/README.md) stack running on the same host (it creates the external `traefik-proxy` network).
- The NFS share mounted at `/mnt/nfs/apps/gitea`, writable by UID/GID `1010`.

## Setup

```shell
cp .env.example .env
# set real passwords in .env, then:
docker compose up -d
```

Open the web UI and create the admin account. The container runs as UID/GID `1010` (`USER_UID`/`USER_GID` in the compose file); change them if your host IDs differ.

Clone over SSH with `git clone ssh://git@git.home:2223/zainibeats/homelab.git`, or over HTTP with `git clone http://git.home:3331/zainibeats/homelab`.

## Configuration

- `GITEA__database__NAME` - Database name Gitea uses. Must equal `MYSQL_DATABASE`.
- `GITEA__database__USER` - Database user Gitea logs in as. Must equal `MYSQL_USER`.
- `GITEA__database__PASSWD` - That user's password. Must equal `MYSQL_PASSWORD`.
- `MYSQL_ROOT_PASSWORD` - MySQL root password.
- `MYSQL_USER` - User MySQL creates on first start.
- `MYSQL_PASSWORD` - Password for `MYSQL_USER`.
- `MYSQL_DATABASE` - Database MySQL creates on first start.
- `DOMAIN` - Base domain for the Traefik routes.
- `SUBDOMAIN` - LAN subdomain for the second route (`git.${SUBDOMAIN}.${DOMAIN}`).

The database host (`db:3306`) and type (`mysql`) are fixed in the compose file.

## Routing & Ports

- `git.${DOMAIN}` and `git.${SUBDOMAIN}.${DOMAIN}` - Web UI through Traefik (`websecure`, `cloudflare` resolver).
- `3331` → `3000` - Web UI.
- `2223` → `22` - SSH for Git operations.
- Networks: `gitea` (internal, with the database) and the external `traefik-proxy`.

## Data & Backups

- `/mnt/nfs/apps/gitea` → `/data` - Repositories, LFS, attachments, and `gitea/conf/app.ini`. Back this up.
- `/mnt/nfs/apps/gitea/mysql` → `/var/lib/mysql` - MySQL data. Back up with `mysqldump` or while the stack is stopped.
- `/etc/timezone`, `/etc/localtime` (read-only) - Host timezone.

## Troubleshooting

- Gitea can't connect to the database: confirm the `GITEA__database__*` values match the `MYSQL_*` values. MySQL only applies `MYSQL_*` on first start with an empty data directory.
- SSH clones fail: use port `2223` (`ssh://git@<host>:2223/...`).
