# Valheim Server

Docker Compose stack for a Valheim server, reachable privately over NetBird on the `services` network.

## Deployment

Copy the example environment file and update the Valheim settings and `VALHEIM_IP`:

```bash
cp .env.example .env
```

Start the stack from this directory:

```bash
docker compose up -d
```

## Remote Access

The stack publishes no ports. It joins the `services` network at `VALHEIM_IP` (e.g. `10.110.2.42`), which [NetBird Client](../../infrastructure/netbird-client/README.md) routes to peers; start that first. Players connect through NetBird to that address.

For shared remote access guidance, see the [Gaming Services README](../README.md#remote-access).

## Ports

Allow these to the `services` resource in the NetBird policy:

- `2456-2458/udp` - Valheim game ports
- `9001/tcp` - Valheim query port

## Data

- `./config` - Valheim server configuration
- `./data` - Persistent Valheim server data
