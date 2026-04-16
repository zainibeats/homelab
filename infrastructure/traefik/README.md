# Traefik

Traefik acts as the edge router and reverse proxy for the homelab, handling SSL termination via Cloudflare DNS challenge.

## Features

- **Docker Integration**: Automatically discovers and configures services running in Docker containers.
- **Automated SSL/TLS**: Uses Let's Encrypt with Cloudflare DNS challenge for automatic certificate management.
- **HTTPS Redirection**: Enforces secure connections by redirecting all HTTP traffic to HTTPS.

## Configuration

The setup relies on:
- `docker-compose.yml`: Service definition and labels.
- `config/traefik.yml`: Static configuration (entrypoints, providers, resolvers).
- `.env`: Sensitive credentials (e.g., `CF_DNS_API_TOKEN`).

> Before starting the container, ensure that `./letsencrypt/acme.json` has its permissions set to `600` (`chmod 600 ./letsencrypt/acme.json`).
