# ConvertX

ConvertX is a simple yet powerful file conversion service that allows you to convert between various file formats. It provides a web interface for easy file conversion.

## Configuration

Before starting the service, ensure you have:

1. Set a secure `JWT_SECRET` environment variable in `docker-compose.yml` for authentication.

## Volumes

- `./data:/app/data` - Stores converted files and application data

## Ports

- `3000` - Web interface and API