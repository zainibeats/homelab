# Neko

Neko is a self-hosted virtual browser (Brave) that runs in Docker and streams to your web browser over WebRTC. This stack routes all browser traffic through a VPN with Gluetun and uses NVIDIA hardware encoding (NVENC).

Good for:

- **Watch parties:** synchronized viewing sessions with shared playback control.
- **Secure remote access:** reach apps and devices on the home network while away, without subnet conflicts (e.g. both networks using `192.168.1.x`).
- **No browser extensions:** a dedicated, containerized browser for VPN-routed traffic.
- **More:** embedding content, collaborative browsing, a throwaway browser.

**Runs on:** Application Server

## Prerequisites

- NVIDIA drivers and the NVIDIA Container Toolkit on the host.
- VPN credentials: a commercial provider supported by Gluetun, or your own WireGuard server.
- UDP ports `52000-52100` reachable by clients (forward them if used remotely).

## Setup

```bash
cp .env.example .env
# fill in .env, then:
docker compose up -d
```

Set `NEKO_WEBRTC_NAT1TO1` to the server's external IP so WebRTC can connect.

For a custom WireGuard server (e.g. remote home access) instead of a commercial provider, set these in `.env`:

```conf
VPN_SERVICE_PROVIDER=custom
VPN_TYPE=wireguard
WIREGUARD_ENDPOINT_IP=WIREGUARD_ENDPOINT_IP # External IP of the VPN server; domain names don't seem to work
WIREGUARD_ENDPOINT_PORT=WIREGUARD_ENDPOINT_PORT # Default is 51820; changing it is recommended
WIREGUARD_PUBLIC_KEY=WIREGUARD_PUBLIC_KEY
WIREGUARD_PRIVATE_KEY=WIREGUARD_PRIVATE_KEY
WIREGUARD_PRESHARED_KEY=WIREGUARD_PRESHARED_KEY
WIREGUARD_ADDRESSES=WIREGUARD_ADDRESSES
```

Find each provider's settings in the [Gluetun wiki](https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers).

## Configuration

- `TZ` - Timezone, e.g. `America/Los_Angeles`.
- `VPN_SERVICE_PROVIDER` - Gluetun provider (`mullvad`, `protonvpn`, `nordvpn`, ... or `custom`).
- `VPN_TYPE` - `wireguard` or `openvpn`.
- `WIREGUARD_PUBLIC_KEY` - WireGuard public key.
- `WIREGUARD_PRIVATE_KEY` - WireGuard private key.
- `SERVER_COUNTRIES` - Comma-separated countries to connect through (commercial providers).
- `NEKO_MEMBER_MULTIUSER_USER_PASSWORD` - Password for regular users.
- `NEKO_MEMBER_MULTIUSER_ADMIN_PASSWORD` - Password for the admin user.
- `NEKO_WEBRTC_NAT1TO1` - The server's external IP address, advertised to WebRTC clients.
- `NEKO_WEBRTC_IP_RETRIEVAL_URL` - URL used to look up the external IP (Neko's default, `https://checkip.amazonaws.com`).

Fixed in the compose file: Brave with an NVENC H.264 pipeline at `1920x1080@30`, multiuser auth, WebRTC ports `52000-52100`, ICE-lite.

## Routing & Ports

Neko shares Gluetun's network namespace, so Gluetun publishes its ports:

- `8880` → `8080` - Neko web interface.
- `52000-52100/udp` - WebRTC media.
- Gluetun sits on `neko-network` (`172.77.0.0/24`) at `172.77.0.2`.
- The Application Server's Traefik reaches Neko through the file-based routes in `networking/traefik/config/dynamic/ubuntu-server*.yml`.

## Data & Backups

- `./gluetun` → `/gluetun` - Gluetun data (server lists).
- `./brave-profile` → Brave profile (bookmarks, logins, extensions). Back this up if you keep logins in it.

## Troubleshooting

- Neko never starts: it waits for Gluetun's health check (`ping www.mullvad.net`). Check `docker logs gluetun-neko` for VPN errors.
- Video connects but stays black or fails: confirm `NEKO_WEBRTC_NAT1TO1` and that the UDP range is reachable.
- See the [Neko documentation](https://neko.m1k1o.net/docs/v3/quick-start).
