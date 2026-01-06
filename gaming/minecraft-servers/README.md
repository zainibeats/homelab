# Minecraft Server

My self‑hosted modded Minecraft server running in Docker. Based on the `itzg/minecraft-server` image and leverages CurseForge to pull the *Essential Perfected Fabric* modpack automatically.

---

## Prerequisites

- Docker Engine
- Docker Compose

The instructions assume the host is a Debian/Ubuntu VM that already has Docker installed.  
WireGuard configurations for remote clients are documented in the [WireGuard README](../../infrastructure/wireguard/README.md).

---

## Deployment

### Docker Compose

A single [docker-compose.yml](./docker-compose.yml) file defines the Minecraft container, while the optional vanilla tweak JSON files ([vanillatweaks-datapacks.json](./config/vanillatweaks-datapacks.json) and [vanillatweaks-resourcepacks.json](./config/vanillatweaks-resourcepacks.json)) located in the `/config` directory are mounted into the container at startup.

> **Note**  
> Replace `YOUR_CF_API_KEY` with a valid CurseForge API key. You can generate one at the [CurseForge Developer Portal](https://console.curseforge.com/developers).  
> `$USERNAME` should be replaced with your Minecraft username or the UUID of operators/whitelisted players.

### Remote VPN Access

WireGuard is required for secure access from outside the local network. The full setup steps are in the [WireGuard README](../../infrastructure/wireguard/README.md). An example minecraft server specifi configuration can be found [here](../../infrastructure/wireguard/templates/minecraft-server-example.conf)

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
| `TYPE` | Modpack type (CurseForge) | `"AUTO_CURSEFORGE"` |
| `CF_API_KEY` | CurseForge API key | `"1234567890abcdef"` |
| `CF_PAGE_URL` | URL of the modpack page | `"https://www.curseforge.com/minecraft/modpacks/essential-perfected-fabric"` |
| `MEMORY` | JVM heap size | `"14336M"` |
| `USE_AIKAR_FLAGS`, `USE_MEOWICE_FLAGS` | Enable recommended performance flags | `"true"` |
| `MAX_PLAYERS` | Max simultaneous players | `"5"` |
| `ENABLE_WHITELIST` | Enable whitelist | `"true"` |
| `OPS` / `WHITELIST` | List of operators/whitelisted usernames separated by newlines | `$USERNAME\nANOTHER_USER` |

### Volume Layout

- `./data` – Persistent world data, server properties, player data.  
- `config/vanillatweaks-datapacks.json` & `...resourcepacks.json` – Optional vanilla datapack/resourcepack overrides.

Mounts are read‑only for the tweak files to prevent accidental modification by the container.

### Modpack & Extra Mods

The container automatically pulls the modpack from CurseForge based on `CF_PAGE_URL`.  
If you want additional mods, add their slugs or IDs to `CURSEFORGE_FILES` (comma/space separated). Example:

```path/to/docker-compose.yml#L30-32
CURSEFORGE_FILES: |
  geckolib
  aquaculture
```

### Vanilla Tweaks

Place JSON files in the `config/` directory and reference them via `VANILLATWEAKS_FILE`. The container will merge these into the server at startup.

### Performance Flags

The `itzg/minecraft-server` image supports a number of JVM flags.  
- `USE_AIKAR_FLAGS=true` enables Aikar’s recommended flags for CPU‑bound workloads.  
- `USE_MEOWICE_FLAGS=true` adds Meowice’s lightweight optimizations (optional).

---

## Running the Server

```bash
# From the project root
docker compose up -d
```

The first run will download the image and the modpack, which may take several minutes depending on your internet speed.

To stop:

```bash
docker compose down
```

---

## Accessing the Server

1. **Inside LAN** – Players can join using the host’s IP address (`<HOST_IP>:25565`).  
2. **Over VPN** – Connect a client to the WireGuard network and use the VPN IP of the host (`10.8.0.1:25565` or whatever subnet you configured).



---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Server never starts | Missing EULA acceptance | Set `EULA=TRUE`. |
| Mods not loading | Incorrect CurseForge API key or URL | Verify `CF_API_KEY` and `CF_PAGE_URL`. |
| VPN traffic blocked | Firewall rules missing | Re‑run `wg-quick up wg0` and check `iptables -L FORWARD`. |
| Player cannot connect via VPN | Port forwarding issue on router | Ensure UDP 51820 (or your custom port) is forwarded to the host. |

For detailed WireGuard troubleshooting, refer to the [WireGuard README](../../infrastructure/wireguard/README.md).
