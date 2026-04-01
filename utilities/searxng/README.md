# SearXNG

SearXNG is a privacy-respecting, self-hosted metasearch engine that aggregates results from multiple search engines without tracking users.

## Volumes

- `/mnt/nfs/apps/searxng/core-config:/etc/searxng/` - SearXNG configuration files
- `core-data` - Search cache
- `valkey-data` - Valkey (Redis-compatible) persistent data

## Ports

- `8086` - Web interface
