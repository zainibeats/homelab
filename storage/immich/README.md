# Immich

Immich is a high-performance self-hosted photo and video backup solution that provides Google Photos-like features.

## Prerequisites

1. SMB share mounted at `/mnt/truenas_data/immich`
2. Proper permissions set on the SMB share (owned by the container user, typically UID 1000)

## Configuration

### 1. SMB Storage Setup

Ensure your SMB share is properly mounted at `/mnt/truenas_data/immich` with the following steps:

```bash
# Create the mount point directories
sudo mkdir -p /mnt/truenas_data/immich/{library,postgres}

# Add to /etc/fstab (replace <smb-server-ip> and </path/on/smb> with your details)
# Example: //192.168.1.100/ImmichData /mnt/truenas_data/immich cifs credentials=/etc/smb_credentials,uid=1000,gid=1000,iocharset=utf8,nofail 0 0
sudo nano /etc/fstab
<smb-server-ip>:<path/on/smb> /mnt/smb/immich cifs credentials=/etc/smb_credentials,uid=1000,gid=1000,iocharset=utf8,nofail 0 0

# Mount the SMB share
sudo mount -a

# Set correct ownership (adjust UID/GID if needed)
sudo chown -R 1000:1000 /mnt/truenas_data/immich
```

### 2. Environment Configuration

Edit the `.env` file with your preferred text editor:

```bash
nano .env
```

Update the following variables:

```ini
# Set your timezone (e.g., America/Los_Angeles, Europe/London)
TZ=America/Los_Angeles

# Set a strong database password
DB_PASSWORD=your_secure_password_here

# Verify the upload location points to your SMB mount
UPLOAD_LOCATION=/mnt/truenas_data/immich/library

# Verify the database location (local storage recommended for DB)
DB_DATA_LOCATION=./postgres
```

## Setup

1. Start the Immich services:

   ```bash
   docker compose up -d
   ```

2. Access the web interface at `http://<your-server-ip>:2283`

3. Create an admin account and start uploading photos

## Data Storage

Immich stores different types of data in the following locations:

- **Media Files**: `/mnt/truenas_data/immich/library` (SMB share)
- **Database**: `./postgres` (local storage)
- **Machine Learning Models**: Docker volume `immich_model-cache`

## Maintenance

### Backups

1. **Media Files**: Since media is stored on the SMB share, ensure you have a backup solution for your NAS.

2. **Database**: Backup the PostgreSQL database regularly:

   ```bash
   docker exec immich_postgres pg_dump -U postgres immich > immich_backup_$(date +%Y%m%d).sql
   ```

## Security Considerations

- Always use strong, unique passwords for the database and admin accounts
- Consider setting up a reverse proxy with HTTPS (e.g., Nginx Proxy Manager)
- Regularly update Immich to receive security patches
- The database should always be stored on local storage, not on SMB

## Troubleshooting

### Permission Issues

If you encounter permission issues with the SMB share:

```bash
# Check the current owner of the SMB directory
ls -la /mnt/truenas_data/immich

# Set correct ownership (adjust UID/GID as needed)
sudo chown -R 1000:1000 /mnt/truenas_data/immich
```

## Documentation

For more detailed documentation, visit the [official Immich documentation](https://immich.app/docs/).
