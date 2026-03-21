# Uptime Kuma

Uptime Kuma is a lightweight, self‑hosted uptime monitoring solution that runs in a single Docker container. It checks HTTP, TCP, DNS, and ping endpoints and can also monitor Docker containers via the Docker socket.

## Quick Start

```bash
docker compose up -d
```

The service is exposed on port **3001**. Data is persisted in the `./data` directory, and the Docker socket is mounted read‑only for container monitoring.

## Directory Structure

```
docker-compose.yml   # Compose definition
./data/              # Persistent storage for monitors, config, and logs
```

## Configuration

- **Data volume**: `./data:/app/data`
- **Docker socket**: `/var/run/docker.sock:/var/run/docker.sock:ro`
- **Port mapping**: `3001:3001`

## Access

- Web UI: `http://<host>:3001`
- API: `/api` (see UI documentation)
