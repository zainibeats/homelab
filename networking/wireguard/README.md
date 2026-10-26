# WireGuard

A self-hosted WireGuard VPN server for remote access to the home network, and an alternative to [NetBird](../netbird-server/README.md). Server config examples are in [`templates/`](./templates): `basic.conf` for a LAN gateway and `minecraft-server.conf`, which forwards only TCP `25565` to one host.

## Prerequisites

- A Debian-based host with `wireguard` and `iptables`: `sudo apt install -y wireguard iptables`.
- A UDP port (default `51820`) forwarded from the router to the host.

## Setup

1. **Generate server keys.** Keep `server_private.key` secret.

   ```bash
   mkdir -p ~/wireguard && cd ~/wireguard
   umask 077
   wg genkey | tee server_private.key | wg pubkey > server_public.key
   ```

2. **Create `/etc/wireguard/wg0.conf`** from a [template](./templates), replacing `<SERVER_PRIVATE_KEY>` with the key above. Set the `PostUp`/`PostDown` interface (`eth0` in the templates) to the host's real one (`ip link`).

3. **Enable IP forwarding.**

   ```bash
   echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-wireguard.conf
   sudo sysctl --system
   ```

4. **Open the port** if ufw is enabled. For clients with static IPs, restrict it with `allow from <CLIENT_IP> to any port 51820 proto udp`.

   ```bash
   sudo ufw allow 51820/udp
   sudo ufw reload
   ```

5. **Start and enable the interface**, then check `sudo wg show` for `wg0` on the right `ListenPort`.

   ```bash
   sudo systemctl enable --now wg-quick@wg0
   ```

### Add a peer

1. Generate the client keys on the server. The preshared key is optional.

   ```bash
   cd ~/wireguard
   wg genkey | tee client1_private.key | wg pubkey > client1_public.key
   wg genpsk > client1.psk
   ```

2. Add a `[Peer]` block to `wg0.conf` (see the templates) with the client's public key and a unique `AllowedIPs = 10.8.0.X/32`, then `sudo systemctl restart wg-quick@wg0`.

3. Create the client config (`client1.conf`):

   ```ini
   [Interface]
   PrivateKey = <CLIENT1_PRIVATE_KEY>
   Address = 10.8.0.2/32
   DNS = 1.1.1.1

   [Peer]
   PublicKey = <SERVER_PUBLIC_KEY>
   # PresharedKey = <CLIENT1_PSK>
   Endpoint = <YOUR_PUBLIC_IP>:51820

   # Full tunnel
   AllowedIPs = 0.0.0.0/0
   # Split tunnel: only VPN and home traffic uses the tunnel
   # AllowedIPs = 10.8.0.0/24, 192.168.1.0/24

   PersistentKeepalive = 25
   ```

   `Endpoint` is the home's public IP or dynamic DNS hostname. `DNS` can be a local resolver (e.g. `192.168.1.100`); if ufw runs on that host, allow it with `sudo ufw allow from 10.8.0.0/24 to any port 53 proto udp`.

4. For phones, show the config as a QR code: `sudo apt install -y qrencode && qrencode -t ansiutf8 < ~/wireguard/client1.conf`.

## Configuration

None. There is no `.env`. The server settings are in `/etc/wireguard/wg0.conf` and the client settings in each client's config.

## Routing & Ports

- `51820/udp` - WireGuard (default; changing `ListenPort` is recommended).
- `10.8.0.0/24` - VPN subnet; the server is `10.8.0.1`.

## Data & Backups

Back up `/etc/wireguard/wg0.conf` and `~/wireguard/` (server and client keys). Both hold private keys.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Address already in use | Ensure other containers are stopped; use `sudo ip link delete wg0`. |
| No traffic through VPN | Ensure `net.ipv4.ip_forward=1` and `PostUp` rules match your active interface (e.g., `eth0`). |
| Handshake fails | Confirm the UDP port (default `51820`) is forwarded on your router to the VPN server's local IP. |
