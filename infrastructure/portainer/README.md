# Portainer

Portainer is a lightweight management UI for Docker. It provides a web interface to manage containers, images, networks, and volumes. This stack runs `portainer/portainer-ce:sts`.

## Prerequisites

- The [Traefik](../../networking/traefik/README.md) stack running on the same host (it creates the external `traefik-proxy` network).

## Setup

```bash
cp .env.example .env
docker compose up -d
```

Open the web UI within a few minutes of the first start and create the admin user; Portainer locks the setup page after a timeout (restart the container to retry).

## Configuration

- `DOMAIN` - Base domain for the Traefik routes (`portainer.${DOMAIN}`).
- `SUBDOMAIN` - LAN subdomain for the second route (`portainer.${SUBDOMAIN}.${DOMAIN}`).

## Routing & Ports

- `portainer.${DOMAIN}` and `portainer.${SUBDOMAIN}.${DOMAIN}` - Web UI through Traefik. Traefik connects to the container's HTTP port `9000`, which is not published.
- `9443` - HTTPS web UI on the host (self-signed certificate).
- Joins the external `traefik-proxy` network.

## Data & Backups

- `portainer_data` volume → `/data` - Portainer settings, users, and endpoints. Back this up.
- `/var/run/docker.sock` - Lets Portainer manage the local Docker daemon (full control of the host's containers).

## Troubleshooting

- "Your Portainer instance timed out for security purposes": restart the container and create the admin user right away.
