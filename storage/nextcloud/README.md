# Nextcloud

Nextcloud is a suite of client-server software for creating and using file hosting services. It provides functionality similar to Dropbox, Office 365, or Google Drive when used with its integrated office suites Collabora Online or OnlyOffice.

## Prerequisites

1. NFS share mounted at `/mnt/nfs/family`
2. Proper permissions set on the NFS share (owned by UID 1005:GID 1005)

## Configuration

### 1. NFS Storage Setup

Ensure your NFS share is properly mounted at `/mnt/nfs/family` with the following steps:

```bash
# Create the mount point and nextcloud directory
sudo mkdir -p /mnt/nfs/family
sudo mkdir -p /mnt/nfs/family/nextcloud

# Add to /etc/fstab (replace <nfs-server-ip> and </path/on/nfs> with your details)
# Example: 192.168.1.100:/mnt/pool/nextcloud /mnt/nfs/family/nextcloud nfs defaults 0 0
sudo nano /etc/fstab
<nfs-server-ip>:<path/on/nfs> /mnt/nfs/family/nextcloud nfs defaults 0 0

# Mount the NFS share
sudo mount -a

# Set correct ownership (adjust UID/GID if needed)
sudo chown -R 1005:1005 /mnt/nfs/family/nextcloud
```

### 2. Database Configuration

Update the following environment variables in `docker-compose.yml`:

1. In the `db` service:
   - `MYSQL_ROOT_PASSWORD`: Choose a strong password for the MariaDB root user
   - `MYSQL_PASSWORD`: Choose a strong password for the Nextcloud database user

2. In the `app` service:
   - Ensure `MYSQL_PASSWORD` matches the one set for the `db` service
   - The `PUID` and `PGID` are set to 1005 by default to match the NFS share permissions

### 3. Port Configuration

By default, Nextcloud is accessible on port 8080. You can modify this in the `ports` section of the `app` service if needed.

## Setup

1.  Navigate to the `nextcloud` directory:
   ```bash
   cd nextcloud
   ```
2.  Start the services using Docker Compose:
```bash
    docker-compose up -d
```

Nextcloud should now be accessible at `http://<your-server-ip>:8080` (or the custom port you configured). Follow the on-screen setup instructions, using `db` as the database host and the database credentials you set in the `docker-compose.yml`. 
