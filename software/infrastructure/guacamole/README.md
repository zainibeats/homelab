# Guacamole

Apache Guacamole is a clientless remote desktop gateway that supports standard protocols like VNC, RDP, and SSH. This setup includes the complete Guacamole stack with PostgreSQL database backend.

## Services

- **Guacamole**: The main web application for remote desktop access
- **Guacd**: The Guacamole proxy daemon that handles remote desktop protocols
- **PostgreSQL**: Database backend for storing connection configurations and user data

## Configuration

### 1. Environment Setup

Before starting the services, you need to configure the database passwords:

1. Replace `<POSTGRES_PASSWORD>` in the docker-compose.yml file with a secure password
2. Ensure both the `postgres` and `guacamole` services use the same password

### 4. Port Configuration

The service is configured to run on port **8088** for use with reverse proxy. If not using a reverse proxy, uncomment the direct port mapping (8080:8080) and comment out the current port mapping.

## Access

- **Web Interface**: http://your-server:8088/guacamole
- **Default Credentials**: `guacadmin` / `guacadmin` (change immediately after first login)

## Data Storage

Guacamole stores data in the following locations:

- **Database**: `./data/` (PostgreSQL data)
- **Recordings**: `./record/` (Session recordings)
- **Shared Files**: `./drive/` (File transfer storage)

## Documentation

For more detailed configuration and usage information, visit the [official Apache Guacamole documentation](https://guacamole.apache.org/doc/gug/).
