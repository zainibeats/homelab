# SearXNG

SearXNG is a privacy-respecting, self-hosted metasearch engine that aggregates results from multiple search engines without tracking users.

## Volumes

- `/mnt/nfs/apps/searxng/core-config:/etc/searxng/` - SearXNG configuration files
- `core-data` - Search cache
- `valkey-data` - Valkey (Redis-compatible) persistent data

## Environment Variables

- **SEARXNG_SECRET** – Secret key used by SearXNG. Generate with `openssl rand -hex 16`
- **DOMAIN** – Traefik domain label
- **SUBDOMAIN** – Traefik subdomain label

## Ports

- `8086` - Web interface

## Open WebUI Integration

SearXNG can be used as the web‑search backend for Open WebUI, but it must return results in JSON. Add the following to `core-config/settings.yml`:

```yaml
formats:
  - html
  - json
```

*See the [Open WebUI](../../automation/ollama-openwebui/README.md) integration guide for details.*
