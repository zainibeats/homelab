# Palworld Server

Docker Compose stack for a Palworld dedicated server with a NetBird client for private remote access.

This stack is present as a reusable game-server template; Minecraft is the currently hosted game server.

## Deployment

Copy the example environment file and update the Palworld and NetBird settings:

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

- `8211/udp` - Palworld game port
- `27015/udp` - Query port

## Data

- `./data` - Persistent Palworld server data
- `./netbird` - NetBird client state
