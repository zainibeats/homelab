# Nginx Proxy Manager + DDClient

This setup includes Nginx Proxy Manager for easy management of reverse proxy configurations and DDClient for automatically updating DNS records with your dynamic IP address (specifically configured for Cloudflare in this example).

## Services

-   **Nginx Proxy Manager**: A web UI for managing Nginx proxy hosts, including free SSL certificate generation and management via Let's Encrypt.
-   **DDClient**: A Perl client used to update dynamic DNS entries for accounts on various dynamic DNS services.

## Configuration

Before starting the services, ensure you have:
1.  Created the necessary host directories for volumes or updated the paths in `docker-compose.yml`:
    *   `./nginx/data`
    *   `./nginx/letsencrypt`
    *   `./config` (for DDClient)
2.  Updated the environment variables for the `ddclient` service:
    *   `TZ`: Your local timezone (e.g., `America/New_York`).
    *   `CF_API_TOKEN`: Your Cloudflare API token with DNS edit permissions.
    *   `CF_EMAIL`: Your Cloudflare account email.
    *   `CF_ZONE`: The domain name (zone) you want to update (e.g., `example.com`).
    *   `CF_RECORD`: The specific record (usually the root domain or a subdomain) you want to update (e.g., `example.com` or `subdomain.example.com`).

## Setup

1.  Navigate to the `nginx-ddclient` directory:
    ```bash
    cd nginx-ddclient
    ```
2.  Start the services using Docker Compose:
    ```bash
    docker-compose up -d
    ```

Nginx Proxy Manager should now be accessible via its admin interface at `http://<your-server-ip>:81`. Default login details are usually `admin@example.com` / `changeme`. DDClient will run in the background and update your Cloudflare DNS record periodically. 
