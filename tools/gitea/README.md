# Gitea

Gitea is a lightweight, self‑hosted Git service that provides a web interface, SSH, REST API, package registry, and CI/CD—all in a single Docker container.

## Deployment

This project uses a `docker-compose.yml` that runs:

- **Image**: `docker.gitea.com/gitea:1.25.4`
- **Database**: MySQL 8 (`db` service). Credentials are supplied from a `.env` file.
- **Data persistence**: `/mnt/nfs/apps/gitea` (app data) and `/mnt/nfs/apps/gitea/mysql` (MySQL data).
- **Ports**:
  - `3331:3000` – HTTP/HTTPS web UI.
  - `222:22` – SSH for Git operations.
- **Volumes**:
  - `/mnt/nfs/apps/gitea:/data`
  - `/etc/timezone:/etc/timezone:ro`
  - `/etc/localtime:/etc/localtime:ro`

### Environment

Create a `.env` file in the same directory with:

```
GITEA__database__NAME=<db_name>
GITEA__database__USER=<db_user>
GITEA__database__PASSWD=<db_passwd>
MYSQL_ROOT_PASSWORD=<root_pw>
MYSQL_USER=<db_user>
MYSQL_PASSWORD=<db_passwd>
MYSQL_DATABASE=<db_name>
```

Replace placeholders with your values.

### Usage

```
docker compose up -d
```

Open web ui to create an admin account. The container runs under UID/GID 1010; adjust if your host UID/GID differ.

Clone repositories via SSH: `git@localhost:222:<repo>` or http: `git clone http://git.home:3331/zainibeats/homelab`.
