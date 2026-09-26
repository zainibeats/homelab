# Valheim Server

Docker Compose stack for a Valheim server with a NetBird client for private remote access.

## Deployment

Copy the example environment file and update the Valheim and NetBird settings:

```bash
cp .env.example .env
```

Start the stack from this directory:

```bash
docker compose up -d
```

## Remote Access

NetBird is the preferred access path for this server. Set `NB_SETUP_KEY` and `NB_MANAGEMENT_URL` in `.env`, then connect clients through the NetBird network.

For shared remote access guidance, see the [Gaming Services README](../README.md#remote-access).

## Ports

- `2456-2458/udp` - Valheim game ports
- `9001/tcp` - Valheim query port

## Data

- `./config` - Valheim server configuration
- `./data` - Persistent Valheim server data
- `./netbird` - NetBird client state
