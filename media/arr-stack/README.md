# Arr Stack

A collection of services for automating media downloads and organization, based on [TechHutTV/homelab](https://github.com/TechHutTV/homelab) and customized:

| Service | Description | Web UI Port |
|---------|-------------|-------------|
| Gluetun | VPN client container | N/A |
| qBittorrent | Torrent download client | 8122 (published by Gluetun, maps to 8123 in the container) |
| Prowlarr | Indexer management | 9696 (published by Gluetun) |
| Sonarr | TV show management | 8989 |
| Radarr | Movie management | 7878 |
| Lidarr | Music management | 8686 |
| Bazarr | Subtitle management | 6767 |
| Seerr | Media requesting | 5055 |
| Deunhealth | Restarts unhealthy containers | N/A |

qBittorrent and Prowlarr share Gluetun's network namespace, so all their traffic goes through the VPN.

## Prerequisites

- The [Traefik](../../networking/traefik/README.md) stack running on the same host (it creates the external `traefik-proxy` network).
- A VPN subscription supported by Gluetun (ProtonVPN, Mullvad, etc.).
- The media NFS share mounted at `/mnt/nfs/jellyfin`, and the app-config share at `/mnt/nfs/apps/arr`:

  ```bash
  # /etc/fstab (replace the server and export path):
  # 192.168.1.100:/mnt/pool/JellyfinData /mnt/nfs/jellyfin nfs defaults 0 0
  sudo mkdir -p /mnt/nfs/jellyfin
  sudo mount -a
  mkdir -p /mnt/nfs/jellyfin/{books,movies,music,tv,youtube}
  mkdir -p /mnt/nfs/jellyfin/downloads/qbittorrent/{completed,incomplete,torrents}
  sudo chown -R 1000:1000 /mnt/nfs/jellyfin
  ```

  For SMB instead, add a CIFS line such as `//192.168.1.100/JellyfinData /mnt/truenas_data/jellyfin_data cifs credentials=/etc/smb_credentials,uid=1000,gid=1000,iocharset=utf8,nofail 0 0` with a `/etc/smb_credentials` file holding `username=` and `password=`.

  Single machine without a NAS: create the same tree under a local directory (e.g. `/data`) and replace the `/mnt/nfs/jellyfin` host paths in `docker-compose.yml`.
- qBittorrent also mounts `/mnt/WD-ExtHDD/Jellyfin` as `/external`; remove that line if the drive isn't attached.

## Setup

```bash
cp .env.example .env
# fill in the VPN settings, then:
docker compose up -d
```

`PUID`/`PGID` are set per service in `docker-compose.yml` (`1000`, except Prowlarr at `1010`). Change them to match the owner of your data (`id $(whoami)`).

Then configure each app:

- **qBittorrent:** log in as `admin` with the temporary password from `docker logs qbittorrent`, then change it in Settings > WebUI. In Advanced settings, set the network interface to `tun0`. In Settings > Downloads, set the default save path to `/data/downloads/qbittorrent/completed`.
- **Prowlarr:** add indexers, then add the apps by their static IPs on `servarrnetwork`: Sonarr `172.69.0.3`, Radarr `172.69.0.4`, Lidarr `172.69.0.5`.
- **Sonarr/Radarr/Lidarr:** add qBittorrent as the download client and set root folders: `/tv` for Sonarr (`/mnt/nfs/jellyfin/tv`), `/movies` for Radarr (`/mnt/nfs/jellyfin/movies`), `/data` for Lidarr (`/mnt/nfs/jellyfin/music/itunes-archive`). Lidarr's `/data` is only the music archive, so it can't see `/data/downloads`.
- **Bazarr:** connect Sonarr and Radarr, then add subtitle providers.
- **Seerr:** connect Sonarr and Radarr so approved requests download automatically.

## Configuration

- `TZ` - Timezone, e.g. `America/Los_Angeles`.
- `VPN_SERVICE_PROVIDER` - Gluetun provider (e.g. `protonvpn`).
- `VPN_TYPE` - `wireguard` or `openvpn`.
- `WIREGUARD_PUBLIC_KEY` - WireGuard public key from your VPN config.
- `WIREGUARD_PRIVATE_KEY` - WireGuard private key from your VPN config.
- `SERVER_COUNTRIES` - Comma-separated countries, no spaces after commas; must match your VPN config.
- `HEALTH_VPN_DURATION_INITIAL` - Gluetun's initial VPN health-check window (`120s`).
- `DOMAIN` - Base domain for the Traefik routes (`sonarr.${DOMAIN}`, etc.).
- `SUBDOMAIN` - LAN subdomain for the second routes (`sonarr.${SUBDOMAIN}.${DOMAIN}`, etc.).

## Routing & Ports

- Traefik routes `sonarr`, `radarr`, `lidarr`, `bazarr`, and `seerr` at `<app>.${DOMAIN}` and `<app>.${SUBDOMAIN}.${DOMAIN}`. qBittorrent and Prowlarr sit behind Gluetun and are routed through the file-based config in `networking/traefik/config/dynamic/application-server*.yml`.
- Host ports: `8122` (qBittorrent UI), `6881` (torrent), `9696` (Prowlarr), `8989`, `7878`, `8686`, `6767`, `5055`.
- Networks: `servarrnetwork` (static IPs, Gluetun at `172.69.0.2`) and the external `traefik-proxy`.

## Data & Backups

- `/mnt/nfs/jellyfin` → `/data` - Media library and downloads.
- `/mnt/nfs/apps/arr/{gluetun,sonarr,radarr,lidarr,bazarr,seerr}` - App configs (NFS). Back these up.
- `./qbittorrent`, `./prowlarr` - qBittorrent and Prowlarr configs next to the compose file (gitignored). Back these up.

## Troubleshooting

- Test the VPN: `docker run --rm --network=container:gluetun alpine:3.18 sh -c "apk add wget && wget -qO- https://ipinfo.io"`. The IP should belong to the VPN provider.
- qBittorrent stalls when the VPN drops: set its network interface to `tun0`. `deunhealth` restarts qBittorrent automatically when it turns unhealthy.
- Gluetun uses a lot of RAM: add `BLOCK_MALICIOUS=off` to its environment.
