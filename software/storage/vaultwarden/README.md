# Vaultwarden

Vaultwarden is an unofficial, lightweight implementation of the Bitwarden server API written in Rust. It provides the same functionality as the official Bitwarden server but with lower system requirements.

## Prerequisites

1. NFS share for persistent data `/mnt/nfs/encrypted`
2. Proper permissions set on the NFS share (owned by the container user, typically UID 1000)

## Configuration

### 1. NFS Storage Setup

Ensure your NFS share is properly mounted at `/mnt/nfs/encrypted` with the following steps:

```bash
# Create the mount point directory and vaultwarden directory
sudo mkdir -p /mnt/nfs/encrypted
sudo mkdir -p /mnt/nfs/encrypted/vaultwarden

# Add to /etc/fstab (replace <nfs-server-ip> and </path/on/nfs> with your details)
# Example: 192.168.1.100:/mnt/pool/encrypted /mnt/nfs/encrypted nfs defaults 0 0
sudo nano /etc/fstab
<nfs-server-ip>:<path/on/nfs> /mnt/nfs/encrypted nfs defaults 0 0

# Mount the NFS share
sudo mount -a

# Set correct ownership (adjust UID/GID if needed)
sudo chown -R 1000:1000 /mnt/nfs/encrypted/vaultwarden
```

## Data Storage

Vaultwarden stores all its data in the following location:

- **Data Directory**: `/mnt/nfs/encrypted/vaultwarden` (NFS share)

## Maintenance

### Backups

Since data is stored on the NFS share, ensure you have a backup solution for your NAS. The following files are important to back up:

- `config.json` - Server configuration
- `db.sqlite3` - Main database file (if using SQLite)
- `attachments/` - Any file attachments
- `sends/` - "Send" items
- `icon_cache/` - Website icons

## Documentation

For more detailed documentation, visit the [official Vaultwarden wiki](https://github.com/dani-garcia/vaultwarden/wiki).