# Jellyfin

[Jellyfin](https://jellyfin.org/) is a free and open-source media server software that allows you to take control of your media. Stream to any device from your own server, with no strings attached. Your media, your server, your rules.

## Volumes

**Note:** The volume mappings preserve the exact directory structure from the original bare metal installation. This ensures compatibility when migrating from a bare metal Jellyfin setup to Docker, as the internal container paths must match the external host paths for configuration and data consistency.

- `/etc/jellyfin` - Contains Jellyfin configuration files
- `/var/cache/jellyfin` - Contains cached data
- `/var/lib/jellyfin` - Contains media library data and metadata
- `/var/log/jellyfin` - Contains Jellyfin log files
- `/mnt/truenas_data/jellyfin_data` - Main media storage

## Documentation

For more information, visit the [official Jellyfin documentation](https://jellyfin.org/docs/).
