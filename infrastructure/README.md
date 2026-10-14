# Infrastructure Services

This directory contains infrastructure services that handle networking, remote access, monitoring, dashboards, and proxy management for the homelab.

## Services Overview

### Dashboard
- **[Homepage (Public)](./homepage-public/README.md)** - Public dashboard aggregating service status and APIs
- **[Homepage (Admin)](./homepage-admin/README.md)** - Administrator dashboard for internal services

### Documentation
- **[Wiki.js](./wiki-js/README.md)** - Self-hosted documentation and knowledge base platform backed by PostgreSQL

### Communication
- **[Matrix](./matrix/README.md)** - Private Matrix homeserver (Synapse) with Element Web and LiveKit calls, reachable only over NetBird

### Container Management
- **[Watchtower](./watchtower/README.md)** - Automatic Docker container update service that monitors and updates running containers on a schedule
- **[Portainer](./portainer/README.md)** - Lightweight UI for managing Docker environments, including containers, images, networks, and volumes

### Version Control
- **[Gitea](./gitea/README.md)** - Self-hosted Git service for repository management
