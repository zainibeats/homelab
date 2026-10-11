# Arr Stack

This setup is based on the configuration provided by [TechHutTV/homelab](https://github.com/TechHutTV/homelab), customized for personal needs.

## Overview

The "Arr Stack" is a collection of services for managing and automating media downloads and organization. This setup includes:

- **VPN Protection**: All download traffic is routed through a VPN using Gluetun
- **Download Client**: qBittorrent (torrents)
- **Media Management**: Sonarr, Radarr, Lidarr, and Bazarr
- **Indexer Management**: Prowlarr
- **Additional Tools**: Seerr

## Components

| Service | Description | Web UI Port |
|---------|-------------|-------------|
| Gluetun | VPN client container | N/A |
| qBittorrent | Torrent download client | 8122 (published by Gluetun, maps to 8123 in the container) |
| Prowlarr | Indexer management | 9696 |
| Sonarr | TV show management | 8989 |
| Radarr | Movie management | 7878 |
| Lidarr | Music management | 8686 |
| Bazarr | Subtitle management | 6767 |
| Seerr | Media Requesting | 5055 |
| Deunhealth | Container health monitor | N/A |

## Network Architecture

This stack uses a custom Docker network (`servarrnetwork`) with static IP addresses for each service. The download client (qBittorrent) and Prowlarr route their traffic through the Gluetun VPN container for privacy and security.

## Prerequisites

1. Docker and Docker Compose installed
2. A VPN subscription (ProtonVPN, Mullvad, etc.)
3. A dedicated data directory for all media and downloads, mounted at `/data` in the containers (see setup below)
4. User permissions set correctly (PUID/PGID)

## Setup Instructions

### 1. Prepare Data Directory Structure

All services are configured to use a single `/data` directory structure inside the containers. This approach simplifies permissions and path management across all containers. You have two options:

- **Option 1 (NFS)** is what this stack's `docker-compose.yml` uses: the NFS share is mounted on the host at `/mnt/nfs/jellyfin` and the compose file mounts it into the containers as `/data`.
- **Option 2 (local)** works too, but you must change the `/mnt/nfs/jellyfin` host paths in `docker-compose.yml` to `/data`.

#### Option 1: NFS Mount (Used by `docker-compose.yml`)

If you're using a separate NAS or file server, mount your NFS share on the host at `/mnt/nfs/jellyfin`:

```bash
# Replace <nfs-server-ip> and <exported/path> with your NFS server details
# Example: 192.168.1.100:/mnt/pool/JellyfinData /mnt/nfs/jellyfin nfs defaults 0 0
sudo nano /etc/fstab
<nfs-server-ip>:<exported/path> /mnt/nfs/jellyfin nfs defaults 0 0

# Optionally, you can add smb mounts to fstab file
# Example: //192.168.1.100/JellyfinData /mnt/truenas_data/jellyfin_data cifs credentials=/etc/smb_credentials,uid=1000,gid=1000,iocharset=utf8,nofail 0 0
# Create the credentials file and replace your-username and your-password with smb user credentials
sudo nano /etc/smb_credentials
username=your-username
password=your-password

# Create the nfs mount point and mount (for smb, use /mnt/smb/jellyfin for example)
sudo mkdir -p /mnt/nfs/jellyfin
sudo mount -a

# Create the directory structure (if not already existing on the NFS share)
mkdir -p /mnt/nfs/jellyfin/{books,movies,music,tv,youtube}
mkdir -p /mnt/nfs/jellyfin/downloads/qbittorrent/{completed,incomplete,torrents}

# Set correct ownership (adjust PUID/PGID as needed)
sudo chown -R 1000:1000 /mnt/nfs/jellyfin
```

#### Option 2: Local Directory (For Single Machine Setup)

If you're not using network storage, use a local `/data` directory and update the `/mnt/nfs/jellyfin` host paths in `docker-compose.yml` to `/data`:

```bash
# Create the main data directory
sudo mkdir -p /data

# Set ownership to your user (replace 1000:1000 with your PUID:PGID if different)
sudo chown -R 1000:1000 /data

# Create the directory structure
mkdir -p /data/{books,movies,music,tv,youtube}
mkdir -p /data/downloads/qbittorrent/{completed,incomplete,torrents}
```

### 2. Configure VPN Settings

Edit the `.env` file and update the Gluetun VPN settings:

```bash
# In arr-stack/.env
VPN_SERVICE_PROVIDER=protonvpn    # Change to your VPN provider
VPN_TYPE=wireguard                # Choose 'wireguard' or 'openvpn'
WIREGUARD_PUBLIC_KEY=<PUBLIC_KEY>  # Replace with your WireGuard public key
WIREGUARD_PRIVATE_KEY=<PRIVATE_KEY> # Replace with your WireGuard private key
SERVER_COUNTRIES=<COUNTRY>         # Comma-separated list of server countries
TZ=<YOUR_TIME_ZONE>                # Set your local timezone
```

### 3. Set User Permissions

Update the PUID and PGID values in the `docker-compose.yml` file to match your user:

```bash
# Find your user ID and group ID
id $(whoami)
# Example output: uid=1000(user) gid=1000(user) groups=...
```

Then update all PUID and PGID values in the compose file accordingly.

### 4. Start the Stack

```bash
cd arr-stack
docker compose up -d
```

## Post-Setup Configuration

### qBittorrent

- Default login: username `admin`, password will be shown in logs the first time
- After login, go to Settings > WebUI to change credentials
- Set network interface to `tun0` in Advanced settings to prevent VPN timeout issues
- In Settings > Downloads, set Default Save Path to `/data/downloads/qbittorrent/completed`

### Prowlarr

- Add your indexers/trackers
- Configure applications (Sonarr, Radarr, etc.) using their internal Docker network IPs:
  - Sonarr: 172.69.0.3
  - Radarr: 172.69.0.4
  - Lidarr: 172.69.0.5

### Sonarr/Radarr/Lidarr

- Add qBittorrent as a download client
- Configure root folders pointing to:
  - `/tv` for Sonarr (mounted from `/mnt/nfs/jellyfin/tv`)
  - `/movies` for Radarr (mounted from `/mnt/nfs/jellyfin/movies`)
  - `/data` for Lidarr (mounted from `/mnt/nfs/jellyfin/music/itunes-archive`). Unlike the other services, Lidarr's `/data` is only the music archive, so it can't see `/data/downloads`
- Connect to Prowlarr for indexers

### Bazarr

- Connect to Sonarr and Radarr
- Configure subtitle providers

### Seerr
- Connect to Sonarr and Radarr for automatic scanning/downloading upon approval

## Troubleshooting

### Testing VPN Connectivity

```bash
docker run --rm --network=container:gluetun alpine:3.18 sh -c "apk add wget && wget -qO- https://ipinfo.io"
```

### qBittorrent Stalls with VPN Timeout

If qBittorrent stalls when the VPN connection drops:

1. In qBittorrent WebUI, go to Advanced settings and set the network interface to `tun0`
2. The `deunhealth` container is already configured to automatically restart qBittorrent if it becomes unhealthy

### Gluetun High RAM Usage

If Gluetun is using excessive RAM, add this environment variable:

```yaml
- BLOCK_MALICIOUS=off
```

### Backing Up Configurations

Service configurations live in two places: Gluetun, Sonarr, Radarr, Lidarr, Bazarr, and Seerr store theirs under `/mnt/nfs/apps/arr/`, while qBittorrent and Prowlarr use `./qbittorrent` and `./prowlarr` next to the compose file. Back these up regularly.

## Security Considerations

- Replace all placeholder values (`<USERNAME>`, `<PASSWORD>`, etc.) with your actual information
- Consider changing default ports for additional security
