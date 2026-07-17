# Gaming Services

This directory contains self-hosted game server stacks and shared infrastructure patterns for running them in the homelab or on OCI Free Tier.

## Services Overview

### Shared Infrastructure
- **[OCI Free Tier](./oci-free-tier/README.md)** - Reusable Terraform configuration for a single OCI Free Tier game server host

### Game Servers
- **[Minecraft](./minecraft/README.md)** - Docker Compose stack for a Minecraft server with optional NetBird remote access
- **[Palworld](./palworld/)** - Docker Compose stack for a Palworld dedicated server

## Common Considerations

### Infrastructure vs Game Runtime
The shared OCI Terraform configuration is intended to manage the reusable host pattern, while each game directory owns its Docker Compose stack, environment variables, and game-specific data.

### Free Tier Limits
OCI Free Tier limits should guide the architecture. Prefer one reusable server pattern with configurable names and ports before duplicating infrastructure per game.

### Persistent Data
Game worlds and server data should stay in each game's directory or documented volume path so backups, restores, and migrations remain clear.
