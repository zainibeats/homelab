# Infrastructure Services

This directory contains infrastructure services that handle networking, remote access, monitoring, dashboards, and proxy management for the homelab.

## Services Overview

### Networking & Proxy
- **[Nginx Proxy Manager + DDClient](./nginx-ddclient/README.md)** - Reverse proxy management with SSL/TLS certificates and dynamic DNS updates for Cloudflare

### Remote Access
- **[Guacamole](./guacamole/README.md)** - Clientless remote desktop gateway supporting VNC, RDP, and SSH protocols with web-based access
- **[Wireguard](./wireguard/README.md)** - WireGuard VPN for secure remote access to homelab and services

### Monitoring
- **[Monitoring](./monitoring/README.md)** - Complete monitoring stack including Prometheus, Grafana, Loki, and cAdvisor for metrics and log aggregation
- **[Uptime Kuma](./uptime-kuma/README.md)** - Service availability monitoring with alerting for uptime and response time

### Dashboard
- **[Homepage](./homepage/README.md)** - Highly customizable dashboard aggregating service status and APIs, with separate admin and public instances

### Container Management
- **[Watchtower](./watchtower/README.md)** - Automatic Docker container update service that monitors and updates running containers on a schedule

### Version Control
- **[Gitea](./gitea/README.md)** - Self-hosted Git service for repository management
