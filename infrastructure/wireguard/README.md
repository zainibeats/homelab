# WireGuard VPN Setup Guide

> Detailed examples are kept in separate `.conf` files under [templates/](./templates).

---

## Prerequisites

* **Port‑forwarded UDP port** – default 51820. Allows clients behind NAT to reach the VPN server.

---

## Install WireGuard

```bash
sudo apt update
sudo apt install -y wireguard iptables
```

Verify: `wg --version`

## Generate Server Keys

```bash
mkdir -p ~/wireguard
cd ~/wireguard
umask 077
wg genkey | tee server_private.key | wg pubkey > server_public.key
```

> Keep `server_private.key` secret; expose only the public key in the config.

---

### 1. Create Server Configuration

Create `/etc/wireguard/wg0.conf`.

Replace `<SERVER_PRIVATE_KEY>` with the contents of `~/wireguard/server_private.key`.

```yaml
[Interface]
PrivateKey = <SERVER_PRIVATE_KEY>
Address = 10.8.0.1/24          ## VPN subnet
ListenPort = 51820             ## Recommended to change from default

## Forward traffic from wg0 to the LAN
## NOTE: eth0 or ens18 is often the default, but verify with 'ip link'
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

```

See server configuration examples [here](./templates)

---

### 2. Enable IP Forwarding

```bash
sudo nano /etc/sysctl.d/99-wireguard.conf
## Add the following line
net.ipv4.ip_forward=1
```

Apply changes:

```bash
sudo sysctl --system
```

Verify: `sysctl net.ipv4.ip_forward`

---

### 3. Start and Enable the Interface

```bash
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

Verify:

```bash
sudo wg show
## Should display interface: wg0, your public key, and ListenPort 51820
```

---

### 4. Firewall Note (ufw)

WireGuard is silent by default and will not respond to unauthorized pings. To allow connections:

```bash
sudo ufw allow 51820/udp
sudo ufw reload
```

> For clients with static IPs, tighten the rule:
> `sudo ufw allow from <CLIENT_IP> to any port 51820 proto udp`.

---

### 5. Add a Peer (Client)

1. **Generate client keys** on the server:
```bash
cd ~/wireguard
wg genkey | tee client1_private.key | wg pubkey > client1_public.key

## Optional: generate a preshared key for extra security
wg genpsk > client1.psk
```

2. **Register the peer** in `/etc/wireguard/wg0.conf`:
```yaml
[Peer]
PublicKey = <CLIENT1_PUBLIC_KEY>
# PresharedKey = <CLIENT1_PSK>  ## include if using a preshared key
AllowedIPs = 10.8.0.2/32    ## Specific VPN IP for this device
```

3. **Restart the interface** to apply changes.
```bash
sudo systemctl restart wg-quick@wg0
```

4. **Create the client config** (`client1.conf`):
```yaml
[Interface]
PrivateKey = <CLIENT1_PRIVATE_KEY>
Address = 10.8.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
# PresharedKey = <CLIENT1_PSK>  ## include if using a preshared key
Endpoint = <YOUR_PUBLIC_IP>:51820

## FULL TUNNEL CONFIGURATION
AllowedIPs = 0.0.0.0/0

## SPLIT TUNNEL CONFIGURATION
## Replace 192.168.1.0/24 with your actual home subnet
# AllowedIPs = 10.8.0.0/24, 192.168.1.0/24

PersistentKeepalive = 25
```

Replace `<YOUR_PUBLIC_IP>` with your home’s external IP or dynamic DNS hostname.

> **Split Tunnel** – Using a comma-separated list in `AllowedIPs` ensures only home-bound traffic uses the VPN. All other internet traffic will bypass the VPN and use the device's local connection.

> **DNS configuration** – The `DNS` setting can be changed to any resolver you prefer. If you have a local DNS server on your home network, set it to that server’s IP (e.g., `192.168.1.100`). If UFW or another firewall is enabled on the DNS host, you may need to allow VPN traffic: `sudo ufw allow from 10.8.0.0/24 to any port 53 proto udp`

---

### 6. Client‑Side Quick Start (QR Code)

```bash
sudo apt install qrencode -y
qrencode -t ansiutf8 < ~/wireguard/client1.conf
```

---

### 7. Troubleshooting Checklist

| Symptom | Check |
| --- | --- |
| Address already in use | Ensure other containers are stopped; use `sudo ip link delete wg0`. |
| No traffic through VPN | Ensure `net.ipv4.ip_forward=1` and `PostUp` rules match your active interface (e.g., `eth0`). |
| Handshake fails | Confirm correct UDP port (default is 51820) is forwarded on your router to the vpn server's local IP. |

---

### 8. Further Reading

* [WireGuard Manual](https://www.wireguard.com/quickstart/)
* [UFW Documentation](https://help.ubuntu.com/community/UFW)
