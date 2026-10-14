# Infrastructure Services

This directory contains infrastructure services that handle networking, remote access, monitoring, dashboards, and proxy management for the homelab.

## Services Overview

### Networking & Proxy
- **[Traefik](./traefik/README.md)** - Edge router and reverse proxy with automated SSL via Cloudflare
- **[DDClient](./ddclient/README.md)** - Dynamic DNS updater for Cloudflare using ddclient docker image

### Remote Access
- **[WireGuard](./wireguard/README.md)** - WireGuard VPN for secure remote access to homelab and services
- **[NetBird Server](./netbird-server/README.md)** - Self-hosted NetBird control plane (management, dashboard, proxy) behind Traefik, pinned to a known installer version
- **[NetBird Client](./netbird-client/README.md)** - NetBird client for secure mesh networking with the homelab, and routing peer for the `services` network

### Monitoring
- **[Monitoring](./monitoring/README.md)** - Home (on-prem) monitoring stack: Prometheus, Grafana, cAdvisor
- **[Monitoring (OCI)](./monitoring-oci/README.md)** - OCI-specific stack with NetBird access for logs and metrics: Prometheus, Grafana, Loki, Alloy 
- **[Uptime Kuma](./uptime-kuma/README.md)** - Service availability monitoring with alerting for uptime and response time

### Dashboard
- **[Homepage](./homepage/README.md)** - Highly customizable dashboard aggregating service status and APIs, with separate admin and public instances

### Documentation
- **[Wiki.js](./wiki-js/README.md)** - Self-hosted documentation and knowledge base platform backed by PostgreSQL

### Communication
- **[Matrix](./matrix/README.md)** - Private Matrix homeserver (Synapse) with Element Web and LiveKit calls, reachable only over NetBird

### Container Management
- **[Watchtower](./watchtower/README.md)** - Automatic Docker container update service that monitors and updates running containers on a schedule
- **[Portainer](./portainer/README.md)** - Lightweight UI for managing Docker environments, including containers, images, networks, and volumes

### Version Control
- **[Gitea](./gitea/README.md)** - Self-hosted Git service for repository management
