# Draw.io

Draw.io is a free, open-source diagramming application for creating flowcharts, network diagrams, org charts, UML diagrams, and more. This self-hosted version provides a web interface accessible via HTTPS.

## Configuration

Before starting the service, ensure you have:

1. Updated `PUBLIC_DNS` in `docker-compose.yml` to match your domain.
2. Set the organization details (`ORGANISATION`, `CITY`, `STATE`, `COUNTRY_CODE`) in `docker-compose.yml` for SSL certificate generation.

## Ports

- `8443` - Web interface (HTTPS)
