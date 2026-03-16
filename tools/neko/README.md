# Neko

Neko is a self-hosted virtual browser that runs in Docker and streams to your web browser via WebRTC. This stack routes all browser traffic through a VPN using Gluetun, making it ideal for various scenarios.

## Key Benefits & Use Cases

This setup is particularly effective for:

- **Watch Parties:** Host synchronized viewing sessions where multiple users can watch streaming content together in real-time with shared playback control.
- **Secure Remote Access:** Safely access applications and devices on your home network when you're away, such as a self-hosted media server or administration panels. Additionally eliminates subnet conflicts (e.g., both your home network and the remote network use the `192.168.1.x` range).
- **Avoid Browser Extensions:** Use a dedicated, containerized browser for VPN-routed traffic without relying on browser extensions.
- **More:** Embedding content, collaborative browsing, throwaway browser, etc.

## Configuration

Before starting the service, ensure you have:

1. Created a `.env` file with your VPN and Neko credentials (see examples below).
2. Set `NEKO_NAT1TO1` to your server's external IP address for WebRTC connectivity.

### Environment Variables

Create a `.env` file with the following variables:

```conf
# Neko Credentials
NEKO_PASSWORD=your_user_password
NEKO_PASSWORD_ADMIN=your_admin_password
NEKO_NAT1TO1=your_external_ip
```

### Custom Wireguard 

For a custom WireGuard configuration (e.g., remote home access), add these to your `.env` file:

```conf
VPN_SERVICE_PROVIDER=custom
VPN_TYPE=wireguard
WIREGUARD_ENDPOINT_IP=WIREGUARD_ENDPOINT_IP # e.g. External IP of VPN server. Domain names do not seem to work
WIREGUARD_ENDPOINT_PORT=WIREGUARD_ENDPOINT_PORT # Default wireguard port is 51820 - recommended to change
WIREGUARD_PUBLIC_KEY=WIREGUARD_PUBLIC_KEY
WIREGUARD_PRIVATE_KEY=WIREGUARD_PRIVATE_KEY
WIREGUARD_PRESHARED_KEY=WIREGUARD_PRESHARED_KEY
WIREGUARD_ADDRESSES=WIREGUARD_ADDRESSES

# Timezone, e.g. America/Los_Angeles
TZ=TIMEZONE
```
Find your VPN provider's configuration in the [Gluetun wiki](https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers) and adjust the environment variables accordingly. The [example .env](./.env.example) can be referenced for configuring your commercial VPN (eg. Mullvad, ProtonVPN, etc.) as well.

## Volumes

- `./gluetun:/gluetun` - Gluetun VPN client data
- `./brave-profile:/home/neko/.config/BraveSoftware/Brave-Browser` - Persistent Brave browser profile

## Ports

- `8880` - Neko web interface
- `52000-52100/udp` - WebRTC media streaming

## Hardware Acceleration

This stack uses NVIDIA GPU hardware encoding (NVENC) for efficient video streaming. Ensure you have:

1. NVIDIA drivers installed on the host
2. NVIDIA Container Toolkit configured for Docker

## Documentation

For more detailed documentation, visit the [official Neko wiki](https://neko.m1k1o.net/docs/v3/quick-start).