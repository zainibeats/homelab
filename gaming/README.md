# Gaming Services

Self-hosted game server stacks for the homelab or reusable cloud hosts. The shared OCI host is managed by [Terraform](../terraform/oci/free-tier-host/README.md); each game directory owns its Compose stack, environment variables, and data.

## Services Overview

- **[Minecraft](./minecraft/README.md)** - Docker Compose stack for a Minecraft server
- **[Palworld](./palworld/README.md)** - Docker Compose stack for a Palworld dedicated server
- **[Valheim](./valheim/README.md)** - Docker Compose stack for a Valheim server

## Remote Access

NetBird is the default way to reach game servers. Game stacks publish no ports: each joins the NetBird-routed `services` network with a static IP instead of exposing game ports to the internet.

This needs [NetBird Server](../networking/netbird-server/README.md) (mine runs on an OCI Always Free `VM.Standard.A1.Flex`) and [NetBird Client](../networking/netbird-client/README.md) as the routing peer for `services`. Each game sets its address in `.env`:

| Game | Variable | Address | Ports to allow in the NetBird policy |
|------|----------|---------|--------------------------------------|
| Minecraft | `MINECRAFT_IP` | `10.110.2.40` | TCP 25565 |
| Palworld | `PALWORLD_IP` | `10.110.2.41` | UDP 8211, 27015 |
| Valheim | `VALHEIM_IP` | `10.110.2.42` | UDP 2456-2458 |

Players connect through NetBird to `<address>:<port>`. [WireGuard](../networking/wireguard/README.md) works as an alternative.
