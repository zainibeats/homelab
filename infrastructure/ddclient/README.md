# DDClient

A Perl client used for automatically updating DNS records with your dynamic IP address (specifically configured for Cloudflare in this example).

## Configuration

Before starting the services, ensure you have updated the environment variables for the `ddclient` service:
    *   `TZ`: Your local timezone (e.g., `America/Los_Angeles`).
    *   `CF_API_TOKEN`: Your Cloudflare API token with DNS edit permissions.
    *   `CF_EMAIL`: Your Cloudflare account email.
    *   `CF_ZONE`: The domain name (zone) you want to update (e.g., `example.com`).
    *   `CF_RECORD`: The specific record (usually the root domain or a subdomain) you want to update (e.g., `example.com` or `subdomain.example.com`).

*DDClient will run in the background and update your Cloudflare DNS record periodically.*
