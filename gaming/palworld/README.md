# Palworld Server

Docker Compose stack for a Palworld dedicated server, reachable privately over NetBird on the `services` network.

## Deployment

Copy the example environment file and update the Palworld settings and `PALWORLD_IP`:

```bash
cp .env.example .env
```

Start the stack from this directory:

```bash
docker compose up -d
```

## Remote Access

The stack publishes no ports. It joins the `services` network at `PALWORLD_IP` (e.g. `10.110.2.41`), which [NetBird Client](../../infrastructure/netbird-client/README.md) routes to peers; start that first. Players connect through NetBird to that address.

For shared remote access guidance, see the [Gaming Services README](../README.md#remote-access).

## Ports

Allow these to the `services` resource in the NetBird policy:

- `8211/udp` - Palworld game port
- `27015/udp` - Query port

## Data

- `./data` - Persistent Palworld server data
