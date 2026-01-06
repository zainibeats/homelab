# Infrastructure Services

This directory contains infrastructure services that handle networking, remote access, monitoring, and proxy management for the homelab.

## Services Overview

### Networking & Proxy
- **[Nginx Proxy Manager + DDClient](./nginx-ddclient/README.md)** - Reverse proxy management with SSL/TLS certificates and dynamic DNS updates for Cloudflare

### Remote Access
- **[Guacamole](./guacamole/README.md)** - Clientless remote desktop gateway supporting VNC, RDP, and SSH protocols with web-based access
- **[Wireguard](./wireguard/README.md)** - Wireguard VPN for secure remote access to homelab and services

### Monitoring
- **[Monitoring](./monitoring/README.md)** - Complete monitoring stack including Prometheus, Grafana, Node Exporter, and cAdvisor for system and container monitoring
