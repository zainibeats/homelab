# Infrastructure Services

This directory contains infrastructure services that handle networking, remote access, monitoring, dashboards, and proxy management for the homelab.

## Services Overview

### Networking & Proxy
- **[Traefik](./traefik/README.md)** - Edge router and reverse proxy with automated SSL via Cloudflare
- **[DDClient](./ddclient/README.md)** - Dynamic DNS updater for Cloudflare using ddclient docker image

### Remote Access
- **[Guacamole](./guacamole/README.md)** - Clientless remote desktop gateway supporting VNC, RDP, and SSH protocols with web-based access
- **[Wireguard](./wireguard/README.md)** - WireGuard VPN for secure remote access to homelab and services
- **[NetBird Client](./netbird-client/README.md)** - NetBird client for secure mesh networking with the homelab

### Monitoring
- **[Monitoring](./monitoring/README.md)** - Complete monitoring stack including Prometheus, Grafana, Loki, and cAdvisor for metrics and log aggregation
- **[Uptime Kuma](./uptime-kuma/README.md)** - Service availability monitoring with alerting for uptime and response time

### Dashboard
- **[Homepage](./homepage/README.md)** - Highly customizable dashboard aggregating service status and APIs, with separate admin and public instances

### Container Management
- **[Watchtower](./watchtower/README.md)** - Automatic Docker container update service that monitors and updates running containers on a schedule
- **[Portainer](./portainer/README.md)** - Lightweight UI for managing Docker environments, including containers, images, networks, and volumes

### Version Control
- **[Gitea](./gitea/README.md)** - Self-hosted Git service for repository management
