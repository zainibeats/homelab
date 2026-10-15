# Valheim Server

Docker Compose stack for a Valheim dedicated server (`tsxcloud/valheim-arm`, for the ARM OCI host), reachable privately over NetBird on the `services` network.

**Runs on:** the OCI host (must share the `services` network with netbird-server)

## Prerequisites

- [NetBird Client](../../networking/netbird-client/README.md) running on the host (it routes the `services` network).
- A NetBird policy allowing UDP `2456-2458` to the `services` resource.

## Setup

```bash
cp .env.example .env
# set VALHEIM_IP and the server settings, then:
docker compose up -d
```

The gaming Ansible playbooks don't support Valheim, so deploy it manually.

## Configuration

- `VALHEIM_IP` - Static IP on the `services` network (e.g. `10.110.2.42`). Required.
- `TZ` - Timezone for the cron schedules.
- `SERVER_NAME` - Name shown in the server browser.
- `WORLD_NAME` - World save name.
- `SERVER_PASS` - Password to join (Valheim requires at least 5 characters).
- `SERVER_PUBLIC` - List publicly (`false`).
- `UPDATE_CRON` - When to check for updates (`0 4 * * *`).
- `BACKUPS` - Enable scheduled backups.
- `BACKUPS_CRON` - Backup schedule (`0 3 * * *`).
- `RESTART_CRON` - Restart schedule (`0 5 * * *`).

## Routing & Ports

- No published ports. The container joins the external `services` network at `VALHEIM_IP`; players connect through NetBird to that address.
- `2456-2458/udp` - Valheim game and query ports.
- See the [Gaming README](../README.md#remote-access) for shared remote access guidance.

## Data & Backups

- `./config` - Valheim server configuration and world saves (`IronGate/Valheim`). Back this up.
- `./data` - Server installation files; re-downloaded if lost.

## Troubleshooting

- `docker compose up` fails with "set VALHEIM_IP in .env": copy `.env.example` and set the IP.
- Players can't connect: check the NetBird policy allows UDP 2456-2458 and that netbird-client routes `services`.
