# DDClient

DDClient is a lightweight dynamic DNS updater that keeps your Cloudflare DNS records in sync with your public IP address.

## Docker Image

The service runs the official `linuxserver/ddclient` image:

```bash
docker pull linuxserver/ddclient:latest
```

## Configuration

All configuration is provided via the `ddclient.conf` file located in the `config/` directory.  
Typical settings include:

- `daemon=300` – check every 5 minutes
- `syslog=yes` – log updates to syslog
- `ssl=yes` – enable SSL for API calls
- `use=web, web=ipify-ipv4` – obtain the public IP from ipify
- Cloudflare block:
  ```conf
  protocol=cloudflare
  zone=<your-domain>
  ttl=1
  login=token
  password=<api-token>
  subdomain.<your-subdomain>
  ```

Replace `<your-domain>`, `<api-token>`, and the subdomain placeholder with your actual values.

---

For more details, consult the official [DDClient documentation](https://github.com/ddclient/ddclient).
