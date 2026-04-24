# Traefik

Traefik acts as the edge router and reverse proxy for the homelab, handling SSL termination via Cloudflare DNS challenge.

## Configuration

The setup relies on:
- `docker-compose.yml`: Service definition and labels.
- `config/traefik.yml`: Static configuration (entrypoints, providers, resolvers).
- `config/dynamic/`: 
- `.env`: Sensitive credentials (e.g., `CF_DNS_API_TOKEN`).

> Before starting the container, ensure that `./letsencrypt/acme.json` has its permissions set to `600` (`chmod 600 ./letsencrypt/acme.json`).
