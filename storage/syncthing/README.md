# Syncthing

[Syncthing](https://syncthing.net/) is a continuous file synchronization program that synchronizes files between two or more computers in real time, safely protected from prying eyes. Your data is your data alone and you deserve to choose where it is stored, whether it is shared with some third party, and how it's transmitted over the internet.

## Configuration

1. Edit the `docker-compose.yml` file and update the following:
   - Set `hostname` to your preferred device name
   - Update the volume paths to point to your desired storage location
   - Adjust `PUID` and `PGID` to match your system's user and group IDs

## Volumes

- `/var/syncthing` - Contains all Syncthing data and configuration
  - Mapped to `${SYNCTHING_DATA}` on the host
- `/var/syncthing/config` - Contains Syncthing configuration
  - Mapped to `./config` (relative to the docker-compose.yml file)

**Note:** If the configuration directory is not on the host machine (e.g. external drive), you can adjust the mapping in the `docker-compose.yml` file.

## Ports

- `21027/udp` - For discovery communication
- `21027/tcp` - For sync protocol traffic
- `22000/tcp` - For sync protocol traffic
- `8384/tcp` - Web GUI (HTTP)
- `22067/tcp` - HTTPS GUI (if enabled)

## Documentation

For more information, visit the [official Syncthing documentation](https://docs.syncthing.net/).
