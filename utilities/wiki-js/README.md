# Wiki.js

Wiki.js is a self-hosted documentation and knowledge base platform. This stack runs Wiki.js with PostgreSQL and exposes the web interface through Traefik.

## Configuration

Before starting the service, ensure you have:

1. Copied `.env.example` to `.env`.
2. Set secure PostgreSQL credentials in `.env`.
3. Set `DOMAIN` and `SUBDOMAIN` for the Traefik routes.
4. Created the external `traefik-proxy` Docker network.

The Wiki.js database variables should match the PostgreSQL variables:

- `DB_USER` should match `POSTGRES_USER`
- `DB_PASS` should match `POSTGRES_PASSWORD`
- `DB_NAME` should match `POSTGRES_DB`

## Volumes

- `db-data:/var/lib/postgresql/data` - Stores PostgreSQL database files

## Ports

- `8839` - Wiki.js web interface
- `3000` - Internal Wiki.js container port used by Traefik

## Git Storage Note

SSH-based Git storage did not work when using a custom SSH port, even after allowing the Docker network to reach that port with a URL like:

```text
ssh://user@server:port/path/to/git/dir
```

HTTP also did not work with a standard account password. Using a personal access token worked when the Git URL used the machine's local IP address, for example:

```text
http://192.168.1.100:3331/path/to/git/repo
```
