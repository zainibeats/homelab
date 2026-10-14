# DDClient

DDClient is a lightweight dynamic DNS updater that keeps Cloudflare DNS records in sync with the host's public IP address. It runs the `linuxserver/ddclient` image.

**Runs on:** Cloud instances without a static IP

## Prerequisites

- A Cloudflare-managed domain and an API token with `Zone:DNS:Edit` permission for it.

## Setup

```shell
mkdir -p config
cp ddclient.example.conf config/ddclient.conf
# edit config/ddclient.conf, then:
docker compose up -d
```

`config/` is gitignored, so git never overwrites the live file; the container chowns it to `PUID`.

## Configuration

There is no `.env` file. `PUID=1000`, `PGID=1000` and `TZ=America/Los_Angeles` are set in `docker-compose.yml`.

`config/ddclient.conf` settings from the example:

- `daemon=300` - Check every 5 minutes.
- `syslog=yes` - Log updates to syslog.
- `ssl=yes` - Use SSL for API calls.
- `use=web, web=ipify-ipv4` - Get the public IP from ipify.
- Cloudflare block:
  ```conf
  protocol=cloudflare
  zone=<your-domain>
  ttl=1
  login=token
  password=<api-token>
  subdomain.<your-domain>
  ```

Replace `<your-domain>`, `<api-token>`, and the record name with your values. See the [DDClient documentation](https://github.com/ddclient/ddclient) for every option.

## Routing & Ports

None. The container only makes outbound API calls.

## Data & Backups

- `./config` - Holds `ddclient.conf` (contains the API token). Back it up securely.

## Troubleshooting

- Check `docker logs ddclient` for authentication or zone errors.
- `login=token` is required when `password` is an API token rather than the global API key.
