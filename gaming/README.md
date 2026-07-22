# Gaming Services

This directory contains self-hosted game server stacks for running games in the homelab or on reusable cloud hosts.

NetBird is the preferred way to access game servers remotely. Individual game stacks should include a NetBird client when they need private remote access instead of exposing game ports directly to the internet.

## Services Overview

### Game Servers
- **[Minecraft](./minecraft/README.md)** - Docker Compose stack for a Minecraft server
- **[Palworld](./palworld/README.md)** - Docker Compose stack for a Palworld dedicated server

## Common Considerations

### Remote Access

Use NetBird as the default remote access path for gaming services.

This requires a NetBird management server to be set up first. My deployment runs on an Oracle Cloud Always Free 4-core ARM VPS (`VM.Standard.A1.Flex`) using NetBird's [Self-Hosting NetBird with Authentik](https://netbird.io/knowledge-hub/selfhost-netbird-with-authentik) guide.

For game stacks that include a NetBird client, set these values in the service `.env` file:

| Variable | Purpose | Example |
|----------|---------|---------|
| `NB_SETUP_KEY` | NetBird setup key for enrolling the client | `"A1B2C3..."` |
| `NB_MANAGEMENT_URL` | NetBird management server URL | `"https://netbird.example.com"` |

After the stack is running, connect clients through NetBird and use the server address exposed on the NetBird network.

WireGuard remains a fallback option when NetBird is not available. The full setup steps are in the [WireGuard README](../infrastructure/wireguard/README.md).

### Infrastructure vs Game Runtime
The shared OCI Terraform configuration in [infrastructure](../infrastructure/terraform/oci/free-tier-host/README.md) manages the reusable host pattern, while each game directory owns its Docker Compose stack, environment variables, and game-specific data.

### Free Tier Limits
OCI Free Tier limits should guide the architecture. Prefer one reusable server pattern with configurable names and ports before duplicating infrastructure per game.

### Persistent Data
Game worlds and server data should stay in each game's directory or documented volume path so backups, restores, and migrations remain clear.
