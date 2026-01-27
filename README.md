# Homelab

This repository contains configuration files and documentation for my homelab setup, including Docker Compose configurations, infrastructure details, and hardware specifications. Further details about the hardware powering this homelab are available in the [Hardware](./hardware/README.md) readme.

## 🖥️ Infrastructure Overview
| Device                     | Purpose                                     | OS                     
| -------------------------- | ------------------------------------------- | ----------------------- 
| **TrueNAS Server**         | Centralized storage and backups             | TrueNAS Scale          
| **Ubuntu Server**          | Primary application hosting                 | Ubuntu Server 22.04 LTS 
| **Raspberry Pi**           | Network services, monitoring and automation | Raspberry Pi OS Lite
| **Rackmount Compute Node** | Proxmox VE host & Minecraft servers         | Proxmox VE              

## Project Organization

Services are organized into logical categories for easier management and navigation:
- **[Gaming](./gaming/minecraft-servers/README.md)** - Directory for gaming services, currently hosting only Minecraft servers.
- **[Infrastructure](./infrastructure/README.md)** - Networking, monitoring, proxy, and remote access services
- **[Media](./media/README.md)** - Media automation, management, and streaming services
- **[Storage](./storage/README.md)** - Data storage, backup, and security services
- **[Tools](./tools/README.md)** - Utility services including automation, file sync, and AI capabilities

## Services

Below is a list of all services configured in this repository, organized by category. Each service directory contains a `docker-compose.yml` file and a specific `README.md` with setup instructions.

| Category                   | Services                                    
| -------------------------- | ------------------------------------------- 
| **Gaming**                 | Minecraft Servers             
| **Infrastructure**         | Nginx Proxy Manager + DDClient, Guacamole, Wireguard VPN, Monitoring Stack (Grafana, Prometheus, etc.)
| **Media**                  | Neko, Jellyfin, Arr Stack (Sonarr, Radarr, Lidarr, Bazarr, Prowlarr, NZBGet, qBittorrent, Jellyseerr, Homarr, and Gluetun)
| **Storage & Backup**       | Immich, Nextcloud, Vaultwarden
| **Tools & Utilities**      | Home Assistant, ConvertX, Draw.io, Syncthing, Ollama + Open WebUI, Watchtower

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
    - `ProxmoxData/` (Proxmox Dataset)
      - **Services**:
        - NFS share for Proxmox host (compute node)
  - `/mnt/Barracuda/` (Downloads Storage Pool)
    - `downloads/` (Downloads Dataset)
      - **Services**:
        - General purpose download network share (repurposed desktop HDD) 

- **NFS Shares**:
  - Media: `/mnt/nfs/jellyfin` (for Arr Stack)
  - Nextcloud: `/mnt/nfs/family/nextcloud`
  - Configured in `/etc/fstab` for automatic mounting
  
- **SMB Shares**:
  - Immich: `/mnt/truenas_data/immich`
  - Jellyfin: `/mnt/truenas_data/jellyfin`

## Docker Image Management

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

## Automatic Updates

Utilizing **Watchtower** for automatic Docker container updates.

I've configured it to run daily at 5:00 AM to minimize disruption during peak usage hours. See the [Watchtower documentation](./tools/watchtower/README.md) for configuration details and usage instructions.
