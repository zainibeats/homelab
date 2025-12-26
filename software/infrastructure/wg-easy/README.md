# WG-Easy VPN

[WG-Easy](https://github.com/wg-easy/wg-easy) is the easiest way to run WireGuard VPN + Web-based Admin UI. It provides a simple web interface to manage your WireGuard VPN server and clients.

## Prerequisites

- Docker and Docker Compose installed on your server
- A domain name pointing to your public IP (recommended)
- Port 51820/udp forwarded to your server (if behind NAT). 
    - To avoid automated scans, consider using a different port.

## Ports

- `51820/udp` - WireGuard VPN port
- `51821/tcp` - Web interface

## Security Considerations

- Always use a strong password for the web interface
- Consider using a reverse proxy with HTTPS in front of the web interface
- Keep your server and Docker images up to date
- Limit access to the web interface using a firewall if possible

## Documentation

For more detailed documentation, visit the [WG-Easy GitHub repository](https://github.com/wg-easy/wg-easy).
