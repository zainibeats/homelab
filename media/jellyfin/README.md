# Jellyfin

[Jellyfin](https://jellyfin.org/) is a free and open-source media server. Stream to any device from your own server, with no strings attached. This stack uses NVIDIA GPU transcoding.

## Prerequisites

- NVIDIA drivers and the NVIDIA Container Toolkit on the host (the compose file uses `runtime: nvidia` and reserves all GPUs).
- The media NFS share mounted at `/mnt/nfs/jellyfin` and the app share at `/mnt/nfs/apps/jellyfin` with `config`, `data`, and `log` folders.

## Setup

```bash
docker compose up -d
```

Open `http://<host>:8096` and run the setup wizard. Add libraries from `/mnt/truenas_data/jellyfin_data`, and enable NVENC under Dashboard > Playback > Transcoding.

## Configuration

There is no `.env` file. The compose file sets `JELLYFIN_CACHE_DIR`, `JELLYFIN_CONFIG_DIR`, `JELLYFIN_DATA_DIR`, and `JELLYFIN_LOG_DIR` to the same paths a bare-metal install uses. The container paths match the old bare-metal layout so an existing configuration migrates without path changes.

## Routing & Ports

- `network_mode: host` - Jellyfin listens directly on the host: `8096` (HTTP), plus its DLNA and discovery ports.
- The Application Server's Traefik routes it through the file-based config in `networking/traefik/config/dynamic/ubuntu-server*.yml`.

## Data & Backups

| Host path | Container path | Contents |
|-----------|----------------|----------|
| `/mnt/nfs/apps/jellyfin/config` | `/etc/jellyfin` | Configuration. Back up. |
| `/mnt/nfs/apps/jellyfin/data` | `/var/lib/jellyfin` | Library database and metadata. Back up. |
| `/mnt/nfs/apps/jellyfin/log` | `/var/log/jellyfin` | Logs |
| `/var/cache/jellyfin` | `/var/cache/jellyfin` | Cache (local disk); disposable |
| `/mnt/nfs/jellyfin` | `/mnt/truenas_data/jellyfin_data` | Media library |

## Troubleshooting

- Transcoding falls back to CPU: check `nvidia-smi` on the host and that `docker info` lists the `nvidia` runtime.
- See the [Jellyfin documentation](https://jellyfin.org/docs/).
