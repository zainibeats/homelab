# Storage & Backup Services

This directory contains services focused on data storage, backup, and security for personal and family data.

## Services Overview

### Photo & Video backups

- **[Immich](./immich/README.md)** - Self-hosted photo and video management platform with features similar to Google Photos

### Cloud Storage

- **[Nextcloud](./nextcloud/README.md)** - Comprehensive self-hosted file sync and share platform

### File Sync

- **[Syncthing](./syncthing/README.md)** - Continuous file synchronization program that synchronizes files between two or more computers in real time

### Password Management

- **[Vaultwarden](./vaultwarden/README.md)** - Lightweight self-hosted password manager compatible with Bitwarden clients

## Considerations

### Backup Strategy
These services integrate with TrueNAS for reliable data backup:
- **Vaultwarden**: Stored on encrypted TrueNAS dataset (`encrypted/vaultwarden`)
- **Nextcloud**: Stored on family dataset (`family/nextcloud`)
- **Immich**: Dedicated dataset (`immich/`)

### Network Storage Integration
Services are configured to use NFS/SMB mounts from TrueNAS:
- **NFS Shares**: For example Nextcloud (`/mnt/nfs/family/nextcloud`)
- **SMB Shares**: For Immich and other services requiring Windows compatibility
- Automatic mounting via `/etc/fstab`
