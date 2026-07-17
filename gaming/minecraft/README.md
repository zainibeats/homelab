# Minecraft Server

My self-hosted Minecraft server running in Docker with NetBird for remote access. Based on the `itzg/minecraft-server` image, with optional support for CurseForge modpacks, extra mods, and Vanilla Tweaks.

---

## Prerequisites

- Docker Engine
- Docker Compose

The instructions assume the host is a Debian/Ubuntu VM that already has Docker installed.  

---

## Deployment

### Docker Compose

A single [docker-compose.yml](./docker-compose.yml) file defines the Minecraft container and NetBird client. This is the default deployment path for remote access.

> **Note**  
> `$USERNAME` should be replaced with your Minecraft username or the UUID of operators/whitelisted players.

### NetBird Remote Access

This requires a NetBird server to be set up first. I run mine on an Oracle Cloud Always Free 4-core ARM VPS (VM.Standard.A1.Flex) using NetBird's [Self-Hosting NetBird with Authentik](https://netbird.io/knowledge-hub/selfhost-netbird-with-authentik) guide.

Set `NB_SETUP_KEY` and `NB_MANAGEMENT_URL` in `.env`, then start the default stack with:

```bash
docker compose up -d
```

### WireGuard Alternative

WireGuard is required for secure access from outside the local network. The full setup steps are in the [WireGuard README](../../infrastructure/wireguard/README.md). An example Minecraft server specific configuration can be found [here](../../infrastructure/wireguard/templates/minecraft-server-example.conf)

In brief:

1. Install WireGuard on the host (`apt install wireguard iptables`).  
2. Enable IP forwarding and configure firewall rules that allow traffic from the VPN subnet to reach port `25565`.  
3. Generate server and client keys, then create peer configurations.  
4. Start the service: `sudo systemctl enable wg-quick@wg0 && sudo systemctl start wg-quick@wg0`.

---

## Configuration

### Environment Variables

| Variable | Purpose | Example |
|----------|---------|--------|
| `EULA` | Accept Minecraft EULA | `"TRUE"` |
| `NB_SETUP_KEY` | NetBird setup key for enrolling the client | `"A1B2C3..."` |
| `NB_MANAGEMENT_URL` | NetBird management server URL | `"https://netbird.example.com"` |
| `TZ` | Container timezone | `"America/Los_Angeles"` |
| `MAX_PLAYERS` | Max simultaneous players | `"5"` |
| `MOTD` | Server message of the day | `"Welcome to My Server"` |
| `DIFFICULTY` | Minecraft difficulty | `"2"` |
| `PVP` | Enable player-vs-player combat | `"false"` |
| `LEVEL` | World name | `"My Server"` |
| `SEED` | World seed, or blank for random | `""` |
| `OPS` / `WHITELIST` | List of operators/whitelisted usernames separated by newlines | `$USERNAME\nANOTHER_USER` |

### Optional Modpack Variables

The default compose stack keeps the modpack-specific variables commented out. Uncomment the matching section in [docker-compose.yml](./docker-compose.yml) when you need CurseForge, extra mods, or Vanilla Tweaks.

| Variable | Purpose | Example |
|----------|---------|--------|
| `TYPE` | Modpack type (CurseForge) | `"AUTO_CURSEFORGE"` |
| `CF_API_KEY` | CurseForge API key | `"1234567890abcdef"` |
| `CF_PAGE_URL` | URL of the modpack page | `"https://www.curseforge.com/minecraft/modpacks/essential-perfected-fabric"` |
| `MEMORY` | JVM heap size | `"14336M"` |
| `USE_AIKAR_FLAGS`, `USE_MEOWICE_FLAGS` | Enable recommended performance flags | `"true"` |
| `CURSEFORGE_FILES` | Extra CurseForge mod slugs or IDs | `geckolib aquaculture` |
| `VANILLATWEAKS_SHARECODE` | Vanilla Tweaks share code from the website | `"xxxxxxx"` |
| `VANILLATWEAKS_FILE` | Local Vanilla Tweaks JSON files mounted into the container | `"/config/vanillatweaks-datapacks.json,/config/vanillatweaks-resourcepacks.json"` |
| `REMOVE_OLD_VANILLATWEAKS` | Remove older Vanilla Tweaks entries during startup | `"TRUE"` |

### Volume Layout

- `./data` – Persistent world data, server properties, player data.  
- `config/vanillatweaks-datapacks.json` & `...resourcepacks.json` - Optional vanilla datapack/resourcepack overrides.

When Vanilla Tweaks is enabled, keep these mounts read-only to prevent accidental modification by the container.

### Modpack & Extra Mods

The container can pull a modpack from CurseForge based on `CF_PAGE_URL`.
If you want additional mods, add their slugs or IDs to `CURSEFORGE_FILES` (comma/space separated). Example:

```path/to/docker-compose.yml#L30-32
CURSEFORGE_FILES: |
  geckolib
  aquaculture
```

### Vanilla Tweaks

Place JSON files in the `config/` directory, uncomment the matching read-only volume mounts, and reference them via `VANILLATWEAKS_FILE`. The container will merge these into the server at startup.

### Performance Flags

The `itzg/minecraft-server` image supports a number of JVM flags.  
- `USE_AIKAR_FLAGS=true` enables Aikar’s recommended flags for CPU‑bound workloads.  
- `USE_MEOWICE_FLAGS=true` adds Meowice’s lightweight optimizations (optional).

---

## Running the Server

```bash
# From gaming/minecraft
docker compose up -d
```

The first run will download the image. If you enable the optional CurseForge settings, it will also download the configured modpack, which may take several minutes depending on your internet speed.

To stop:

```bash
docker compose down
```

---

## Accessing the Server

1. **Inside LAN** - Players can join using the host's IP address (`<HOST_IP>:25565`).
2. **Over NetBird** - Connect through NetBird and use the Minecraft server address exposed on that network.
3. **Over WireGuard** - If you choose the WireGuard alternative, connect a client to the WireGuard network and use the VPN IP of the host (`10.8.0.1:25565` or whatever subnet you configured).



---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Server never starts | Missing EULA acceptance | Set `EULA=TRUE`. |
| Mods not loading | Incorrect CurseForge API key or URL | Verify `CF_API_KEY` and `CF_PAGE_URL`. |
| VPN traffic blocked | Firewall rules missing | Re‑run `wg-quick up wg0` and check `iptables -L FORWARD`. |
| Player cannot connect via VPN | Port forwarding issue on router | Ensure UDP 51820 (or your custom port) is forwarded to the host. |

For detailed WireGuard troubleshooting, refer to the [WireGuard README](../../infrastructure/wireguard/README.md).
