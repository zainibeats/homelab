# Minecraft Server

My self-hosted Minecraft server, reachable privately over NetBird. Based on the `itzg/minecraft-server` image, with optional support for CurseForge modpacks, extra mods, and Vanilla Tweaks.

**Runs on:** the OCI host (must share the `services` network with netbird-server)

## Prerequisites

- A Debian/Ubuntu host with Docker Engine and Docker Compose (the [gaming Ansible playbooks](../../ansible/gaming/README.md) can prepare it).
- [NetBird Client](../../networking/netbird-client/README.md) running on the host (it routes the `services` network), and a NetBird policy allowing TCP `25565` to the `services` resource.

## Setup

```bash
cp .env.example .env
# set MINECRAFT_IP and the server settings, then:
docker compose up -d
```

The first run downloads the image, and the modpack too if the CurseForge settings are enabled, which can take several minutes. Stop with `docker compose down`.

### Modpacks and extra mods

The modpack settings are commented out in [docker-compose.yml](./docker-compose.yml). To use them, set the values in `.env` and uncomment the matching lines:

- **CurseForge modpack:** `TYPE`, `CF_API_KEY`, `CF_PAGE_URL`. The container pulls the modpack from `CF_PAGE_URL`.
- **Extra mods:** add CurseForge slugs or IDs to `CURSEFORGE_FILES` (separated by commas, spaces, or newlines):
  ```yaml
  CURSEFORGE_FILES: |
    geckolib
    aquaculture
  ```
- **Vanilla Tweaks:** set `VANILLATWEAKS_SHARECODE`, or put JSON files in `config/`, uncomment the read-only mounts, and set `VANILLATWEAKS_FILE` (`/config/vanillatweaks-datapacks.json,/config/vanillatweaks-resourcepacks.json`). `REMOVE_OLD_VANILLATWEAKS` removes older entries at startup.
- **Performance:** `MEMORY` (JVM heap, e.g. `14336M`), `USE_AIKAR_FLAGS=true` (Aikar's flags for CPU-bound workloads), `USE_MEOWICE_FLAGS=true` (Meowice's lightweight optimizations).

## Configuration

| Variable | Purpose | Example |
|----------|---------|---------|
| `EULA` | Accept the Minecraft EULA (also hard-coded to `TRUE` in compose) | `TRUE` |
| `MINECRAFT_IP` | Static IP on the `services` network | `10.110.2.40` |
| `TZ` | Container timezone | `America/Los_Angeles` |
| `MAX_PLAYERS` | Max simultaneous players | `5` |
| `MOTD` | Server message of the day | `Welcome to My Server` |
| `DIFFICULTY` | Minecraft difficulty | `2` |
| `PVP` | Enable player-vs-player combat | `false` |
| `LEVEL` | World name | `My Server` |
| `SEED` | World seed, or blank for random | |
| `OPERATOR1` | Operator username; also whitelisted | `zainibeats` |
| `USER1` | Extra whitelisted username | `username2` |
| `TYPE` | Modpack type (optional) | `AUTO_CURSEFORGE` |
| `CF_API_KEY` | CurseForge API key (optional) | |
| `CF_PAGE_URL` | Modpack page URL (optional) | |
| `VANILLATWEAKS_SHARECODE` | Vanilla Tweaks share code (optional) | |
| `MEMORY` | JVM heap size (optional) | `14336M` |
| `USE_AIKAR_FLAGS` | Aikar's JVM flags (optional) | `true` |
| `USE_MEOWICE_FLAGS` | Meowice's JVM flags (optional) | `true` |

The whitelist is enabled (`ENABLE_WHITELIST=true`). To add more players, add variables to `.env` and list them under `WHITELIST` (and `OPS`) in the compose file.

## Routing & Ports

- No published ports. The container joins the external `services` network at `MINECRAFT_IP`.
- Players connect through NetBird to `MINECRAFT_IP:25565` (e.g. `10.110.2.40:25565`). See the [Gaming README](../README.md#remote-access).
- WireGuard fallback: the [WireGuard README](../../networking/wireguard/README.md) and the [Minecraft WireGuard template](../../networking/wireguard/templates/minecraft-server.conf). The template forwards TCP `25565` from the tunnel to `<MC_SERVER_IP>`, so clients connect to `MINECRAFT_IP:25565` through the tunnel.

## Data & Backups

- `./data` - World data, server properties, and player data. Back this up.
- `config/vanillatweaks-*.json` - Optional Vanilla Tweaks overrides, mounted read-only when enabled.

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Server never starts | Missing EULA acceptance | Set `EULA=TRUE`. |
| Mods not loading | Incorrect CurseForge API key or URL | Verify `CF_API_KEY` and `CF_PAGE_URL`. |
| Can't reach the server over NetBird | `services` not routed, or port not allowed | Check `docker exec netbird-client netbird status` and that the NetBird policy allows TCP 25565 to the `services` resource. |
| WireGuard traffic blocked | Firewall rules missing | Re-run `wg-quick up wg0` and check `iptables -L FORWARD`. |
| Player cannot connect over WireGuard | Port forwarding issue on router | Ensure UDP 51820, or your custom port, is forwarded to the host. |
