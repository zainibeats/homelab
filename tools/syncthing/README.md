# Syncthing

[Syncthing](https://syncthing.net/) is a continuous file synchronization program that synchronizes files between two or more computers in real time, safely protected from prying eyes. Your data is your data alone and you deserve to choose where it is stored, whether it is shared with some third party, and how it's transmitted over the internet.

## Configuration

1. Edit the `docker-compose.yml` file and update the following:
   - Set `hostname` to your preferred device name
   - Update the volume paths to point to your desired storage location
   - Adjust `PUID` and `PGID` to match your system's user and group IDs

## Volumes

- `/var/syncthing` - Contains all Syncthing data and configuration
  - Mapped to `/<CHOOSE_PATH_FOR_SYNCTHING_DATA>/syncthing` on the host
  - For external storage, consider mounting config separately:

```yaml
- /<CHOOSE_PATH_FOR_SYNCTHING_CONFIG>/syncthing/config:/var/syncthing/config
```

**Note:** If the config directory is not on the host machine (e.g., external drive), you can add the following volume:

```yaml
- /<CHOOSE_PATH_FOR_SYNCTHING_CONFIG>/syncthing/config:/var/syncthing/config
```

On a TrueNAS system, I've used my 'encrypted' dataset for Syncthing data and created a backups directory within it:

```yaml
- /mnt/Ironwolf-Pro-8TB-Mirror/encrypted/backups/syncthing:/var/syncthing
```

## Ports

- `21027/udp` - For discovery communication
- `21027/tcp` - For sync protocol traffic
- `22000/tcp` - For sync protocol traffic
- `8384/tcp` - Web GUI (HTTP)
- `22067/tcp` - HTTPS GUI (if enabled)

## Usage

1. Open the web interface at `http://<your-server-ip>:8384`
2. Follow the setup wizard to configure your instance
3. Add devices by exchanging device IDs
4. Create shared folders and configure sync settings

## Documentation

For more information, visit the [official Syncthing documentation](https://docs.syncthing.net/).