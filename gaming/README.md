# Gaming Services

This directory contains self-hosted game server stacks for running games in the homelab or on reusable cloud hosts.

NetBird is the preferred way to access game servers remotely. Game stacks publish no ports: each joins the NetBird-routed `services` network with a static IP instead of exposing game ports to the internet.

## Services Overview

### Game Servers
- **[Minecraft](./minecraft/README.md)** - Docker Compose stack for a Minecraft server
- **[Palworld](./palworld/README.md)** - Docker Compose stack for a Palworld dedicated server
- **[Valheim](./valheim/README.md)** - Docker Compose stack for a Valheim server

## Common Considerations

### Remote Access

Use NetBird as the default remote access path for gaming services.

This needs [NetBird Server](../infrastructure/netbird-server/README.md) (mine runs on an OCI Always Free `VM.Standard.A1.Flex`) and [NetBird Client](../infrastructure/netbird-client/README.md) as the routing peer for `services`. Each game sets its address in `.env`:

| Game | Variable | Address | Ports to allow in the NetBird policy |
|------|----------|---------|--------------------------------------|
| Minecraft | `MINECRAFT_IP` | `10.110.2.40` | TCP 25565 |
| Palworld | `PALWORLD_IP` | `10.110.2.41` | UDP 8211, 27015 |
| Valheim | `VALHEIM_IP` | `10.110.2.42` | UDP 2456-2458 |

Players connect through NetBird to `<address>:<port>`.

WireGuard may be used as an alternative to Netbird. The full setup steps are in the [WireGuard README](../infrastructure/wireguard/README.md).

### Infrastructure vs Game Runtime
The shared OCI Terraform configuration in [infrastructure](../infrastructure/terraform/oci/free-tier-host/README.md) manages the reusable host pattern, while each game directory owns its Docker Compose stack, environment variables, and game-specific data.

