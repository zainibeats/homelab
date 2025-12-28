# Configuring Wireguard VPN

### Requirements:
- Port forwarded wireguard on home router. Default is 51820/udp

### High-level topology

```bash
Client (Laptop)
   |
[ WireGuard VPN ]
   |
Debian VM
   ├─ WireGuard interface (wg0)
   ├─ Docker bridge (docker0)
   └─ Minecraft container (port 25565)
   ```

# Step 1 — Install WireGuard on the Debian VM

```bash
sudo apt update
sudo apt install -y wireguard iptables
```

Verify:

```bash
wg --version
```

# Step 2 — Enable IP forwarding 

```bash
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-wireguard.conf
sudo sysctl --system
```

Verify:

```bash
sysctl net.ipv4.ip_forward
```

Must return `= 1`

# Step 3 — Generate WireGuard keys (server side)

```bash
umask 077
wg genkey | tee server_private.key | wg pubkey > server_public.key
```

# Step 4 — Create WireGuard server config

```bash
# Edit config
sudo nano /etc/wireguard/wg0.conf

# Paste below
[Interface]
Address = 10.8.0.1/24
ListenPort = 51820 # Replace with custom wireguard port
PrivateKey = <SERVER_PRIVATE_KEY> # Replace with server_private.key

PostUp = iptables -A FORWARD -i wg0 -d <VM_IP> -p tcp --dport 25565 -j ACCEPT
PostUp = iptables -A FORWARD -o wg0 -s <VM_IP> -p tcp --sport 25565 -j ACCEPT
PostUp = iptables -A FORWARD -i wg0 -j DROP
PostUp = iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -d <VM_IP> -o ens18 -j MASQUERADE # Replace ens18 with default network interface ()

PostDown = iptables -D FORWARD -i wg0 -d <VM_IP> -p tcp --dport 25565 -j ACCEPT
PostDown = iptables -D FORWARD -o wg0 -s <VM_IP> -p tcp --sport 25565 -j ACCEPT
PostDown = iptables -D FORWARD -i wg0 -j DROP
PostDown = iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -d <VM_IP> -o ens18 -j MASQUERADE
```

### Replace:
- `<SERVER_PRIVATE_KEY>`
- `ens18` → your actual network interface

Check interface name:

```bash
ip a
```

(Usually `ens18` or `eth0` in Proxmox)

# Step 5 — Start WireGuard

```bash
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

Verify:

```bash
wg
ip a show wg0
```

You should see `10.8.0.1`.

# Step 6 — Add a VPN client (example)
On the **server**:

```bash
wg genkey | tee client1_private.key | wg pubkey > client1_public.key
```

Append to `/etc/wireguard/wg0.conf`:

```bash
[Peer]
PublicKey = <CLIENT1_PUBLIC_KEY>
AllowedIPs = 10.8.0.2/32
```

Reload:

```bash
sudo wg syncconf wg0 <(wg-quick strip wg0)
```

# Step 7 — Client WireGuard config
On the client device:

```bash
[Interface]
PrivateKey = <CLIENT1_PRIVATE_KEY> # Replace with client1_private.key
Address = 10.8.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY> # Replace with server_public.key
AllowedIPs = <VM_IP>/32, 10.8.0.0/24 # Replace with VM IP (eg. 192.168.1.100/32)
Endpoint = <YOUR_HOME_PUBLIC_IP>:51820 # Replace with home ip/domain name and custom wireguard port (if configured)
PersistentKeepalive = 25
```

# Step 8 — Firewall considerations
If UFW is enabled:

```bash
# Replace with home ip and custom wireguard port (if configured)
# Alternatively, allow from only specific ip addresses (eg. sudo ufw allow from <CLIENT_PUBLIC_IP> to any port 51820 proto udp)
sudo ufw allow 51820/udp
sudo ufw reload
```

# Troubleshooting

## Troubleshooting

- **Restart WireGuard**  
  ```bash
  sudo wg-quick down wg0 && sudo wg-quick up wg0
  ```

- **Check forwarding rules**  
  ```bash
  sudo iptables -L FORWARD -v -n --line-numbers
  ```
  Expect:
  ```bash
  ACCEPT  wg0 → <VM_IP> tcp dpt:25565
  ACCEPT  <VM_IP> → wg0 tcp spt:25565
  DROP    wg0 → anywhere
  ```

- **Test connectivity**  
  ```bash
  nc -vz <VM_IP> 25565
  ```
