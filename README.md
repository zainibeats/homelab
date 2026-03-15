# Homelab

This repository contains configuration files and documentation for my homelab setup, including Docker Compose configurations, infrastructure details, and hardware specifications. Further details about the hardware and network powering this homelab are available in the [Hardware](./hardware/README.md) readme.

> For my build processes, insights, stories, photos, and more, visit my [blog](https://blog.czaini.net).

## Infrastructure Overview
| Device                     | Purpose                                       | OS                     
| -------------------------- | --------------------------------------------- | ----------------------- 
| **TrueNAS Server**         | Centralized storage and backups               | TrueNAS Scale          
| **Ubuntu Server**          | Primary application hosting                   | Ubuntu Server 22.04 LTS 
| **Raspberry Pi**           | Network services, monitoring and automation   | Raspberry Pi OS Lite
| **Rackmount Compute Node** | Virtual machines, remote desktop and testing  | Proxmox VE              

## Project Organization

Services are organized into logical categories for easier management and navigation:
- **[Automation](./automation/README.md)** - Home and Docker container automation
- **[Gaming](./gaming/minecraft-servers/README.md)** - Directory for gaming services, currently hosting only Minecraft servers
- **[Infrastructure](./infrastructure/README.md)** - Networking, monitoring, proxy, and remote access services
- **[Media](./media/README.md)** - Media automation, management, and streaming services
- **[Storage](./storage/README.md)** - Data storage, backup, and security services
- **[Tools](./tools/README.md)** - Utility services including secret sharing, file sync, local AI, and more

## Storage Configuration

This homelab is designed with modularity in mind:

- **TrueNAS Datasets**:
  - `/mnt/Ironwolf-Pro-8TB-Mirror/` (Media Storage Pool)
    - `jellyfin_data/`
      - Services: _Jellyfin and arr stack_
  - `/mnt/exos-20tb/` (Application Storage Pool)
    - `apps/`
      - Services: _Gitea_
    - `encrypted/`
      - Services: _Vaultwarden and Syncthing_
    - `ProxmoxData/`
      - Services: _NFS share for Proxmox host (compute node)_
    - `immich/`
      - Services: _Immich_
    - `family/`
      - Services: _Nextcloud_

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
