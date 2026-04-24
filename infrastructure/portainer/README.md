# Portainer

Portainer is a lightweight management UI that allows you to manage your Docker environments. It provides a web interface to manage containers, images, networks, and volumes.

## Volumes

- `/var/run/docker.sock:/var/run/docker.sock` - Allows Portainer to interact with the Docker daemon.
- `portainer_data:/data` - Stores Portainer configuration and data.

## Ports

- `9443` - HTTPS web interface.
