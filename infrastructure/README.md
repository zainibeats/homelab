# Infrastructure Services

This directory contains infrastructure services that handle networking, remote access, monitoring, dashboards, and proxy management for the homelab.

## Services Overview

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
