# Software

This repository contains Docker Compose configurations for various self-hosted services used in my first homelab. The infrastructure is distributed across multiple dedicated machines for isolation (and lack of resources):

## 🖥️ Infrastructure Overview

| Device             | Purpose                                     | OS                      | Key Services                                                                                                                             |
| ------------------ | ------------------------------------------- | ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| **TrueNAS Server** | Centralized storage and backups             | TrueNAS Scale           | ZFS storage, SMB/NFS shares                                                                                                              |
| **Ubuntu Server**  | Primary application hosting                 | Ubuntu Server 22.04 LTS | Docker containers, application services                                                                                                  |
| **Raspberry Pi**   | Network services, monitoring and automation | Raspberry Pi OS Lite    | Pi-Hole, Home Assistant, WG-Easy, Nginx Proxy Manager, DDClient, Grafana, Prometheus, [Taskwise](https://github.com/zainibeats/taskwise) |
| **Debian Server**  | Testing                                     | Debian 12 (headless)    | Powered on to test configurations, services, etc.                                                                                        |

## Project Organization

Services are organized into logical categories for easier management and navigation:

- **[Infrastructure](./infrastructure/README.md)** - Networking, monitoring, proxy, and remote access services
- **[Media](./media/README.md)** - Media automation, management, and streaming services
- **[Storage](./storage/README.md)** - Data storage, backup, and security services
- **[Tools](./tools/README.md)** - Utility services including automation, file sync, and AI capabilities

## Services

Below is a list of all services configured in this repository, organized by category. Each service directory contains a `docker-compose.yml` file and a specific `README.md` with setup instructions.

### Infrastructure ([docs](./infrastructure/README.md))
- **Nginx Proxy Manager + DDClient** ([docs](./infrastructure/nginx-ddclient/README.md)): Reverse proxy management with SSL/TLS certificates and dynamic DNS updates for Cloudflare
- **Guacamole** ([docs](./infrastructure/guacamole/README.md)): Clientless remote desktop gateway supporting VNC, RDP, and SSH protocols with web-based access
- **WG-Easy** ([docs](./infrastructure/wg-easy/README.md)): Easy-to-use Wireguard VPN with a web interface for secure remote access to the homelab
- **Monitoring** ([docs](./infrastructure/monitoring/README.md)): Monitoring stack including Prometheus, Grafana, Node Exporter, and cAdvisor

### Media ([docs](./media/README.md))
- **Arr Stack** ([docs](./media/arr-stack/README.md)): Complete media automation suite including Sonarr, Radarr, Lidarr, Bazarr, Prowlarr, NZBGet, qBittorrent, Jellyseerr, and Homarr dashboard. All download traffic is routed through a VPN (Gluetun) with NFS/SMB for media storage
- **Jellyfin** ([docs](./media/jellyfin/README.md)): Self-hosted media server for streaming movies, TV shows, music, and more

### Storage & Backup ([docs](./storage/README.md))
- **Immich** ([docs](./storage/immich/README.md)): Self-hosted photo and video management platform with automatic backup and AI-powered features
- **Nextcloud** ([docs](./storage/nextcloud/README.md)): Self-hosted file sync and share platform with NFS storage integration
- **Vaultwarden** ([docs](./storage/vaultwarden/README.md)): Self-hosted password manager compatible with the official [Bitwarden](https://bitwarden.com/) app

### Tools & Utilities ([docs](./tools/README.md))
- **Home Assistant** ([docs](./tools/home-assistant/README.md)): Comprehensive home automation platform for controlling and automating smart home devices
- **ConvertX** ([docs](./tools/convertx/README.md)): Simple file conversion service with a web interface
- **Syncthing** ([docs](./tools/syncthing/README.md)): Continuous file synchronization program that synchronizes files between computers in real time
- **Ollama + Open WebUI** ([docs](./tools/ollama-openwebui/README.md)): Run large language models locally with Ollama and interact with them through Open WebUI
- **Watchtower** ([docs](./tools/watchtower/README.md)): Automatic Docker container update service that monitors and updates running containers on a scheduled basis

## Storage Configuration

This homelab is designed with network storage in mind:

- **TrueNAS Datasets and Services**:
  - `/mnt/Ironwolf-Pro-8TB-Mirror/` (Main Storage Pool)
    - `encrypted/` (Encrypted Dataset)
      - **Services**:
        - vaultwarden
        - syncthing
    - `family/` (Family Dataset)
      - **Service**: nextcloud
    - `immich/` (Immich Dataset)
      - **Service**: immich
    - `jellyfin_data/` (Jellyfin Dataset)
      - **Services**:
        - jellyfin
        - arr

- **NFS Shares**:
  - Media: `/mnt/nfs/jellyfin` (for Arr Stack)
  - Nextcloud: `/mnt/nfs/family/nextcloud`
  - Configured in `/etc/fstab` for automatic mounting
  
- **SMB Shares**:
  - Immich: `/mnt/truenas_data/immich`
  - Jellyfin: `/mnt/truenas_data/jellyfin`

## Docker Image Management - Portainer

**Portainer** provides a web-based interface for managing Docker containers, images, networks, and volumes. It offers an intuitive GUI for Docker management tasks that would otherwise require command-line operations.

### Setup

1. Create a Docker volume for Portainer's database:
   ```bash
   docker volume create portainer_data
   ```

2. Run the Portainer container:
   ```bash
   docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:lts
   ```

### Access

- **Web Interface**: `https://<IP_ADDRESS>:9443`

## Prerequisites

-   Docker
-   Docker Compose

## Automatic Updates (Optional)

For automatic Docker container updates, this repository includes a dedicated **Watchtower** service ([docs](./tools/watchtower/README.md)) that monitors running containers and automatically pulls new images and restarts containers when updates are available.

The Watchtower service can be deployed in two ways:
- **Docker Compose**: Use the included docker-compose configuration for centralized management
- **Docker Run**: Run directly on each machine using the `docker run` command

The Watchtower service is configured to run daily at 5:00 AM to minimize disruption during peak usage hours. See the [Watchtower documentation](./tools/watchtower/README.md) for configuration details and usage instructions.

A basic Watchtower container might look like this:

```bash
docker run -d \
--name watchtower \
-v /var/run/docker.sock:/var/run/docker.sock \
containrrr/watchtower
```
