# Networking

Reverse proxy, dynamic DNS, and remote access stacks.

## Services Overview

### Networking & Proxy
- **[Traefik](./traefik/README.md)** - Edge router and reverse proxy with automated SSL via Cloudflare
- **[DDClient](./ddclient/README.md)** - Dynamic DNS updater for Cloudflare using ddclient docker image

### Remote Access
- **[WireGuard](./wireguard/README.md)** - WireGuard VPN for secure remote access to homelab and services
- **[NetBird Server](./netbird-server/README.md)** - Self-hosted NetBird control plane (management, dashboard, proxy) behind Traefik, pinned to a known installer version
- **[NetBird Client](./netbird-client/README.md)** - NetBird client for secure mesh networking with the homelab, and routing peer for the `services` network
