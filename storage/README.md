# Storage & Backup Services

This directory contains services focused on data storage, backup, and security for personal and family data.

## Services Overview

### Photo & Video backups

- **[Immich](./immich/README.md)** - Self-hosted photo and video management platform with features similar to Google Photos

### Cloud Storage

- **[Nextcloud](./nextcloud/README.md)** - Comprehensive self-hosted file sync and share platform
  *Note: Data is stored on NFS share at `/mnt/nfs/apps/nextcloud`.*

### File Sync

- **[Syncthing](./syncthing/README.md)** - Continuous file synchronization program that synchronizes files between two or more computers in real time

### Password Management

- **[Vaultwarden](./vaultwarden/README.md)** - Lightweight self-hosted password manager compatible with Bitwarden clients

### Personal Context

- **[Obsidian Vault](./obsidian-vault)** - A symbolic link to my personal notes and tasks. This directory is ignored by git and is not visible to the public, but provides extra context for humans and AI agents regarding the homelab.

## Storage Notes

These services use NAS-backed storage with separate datasets for application data, photos, private files, and backups.
