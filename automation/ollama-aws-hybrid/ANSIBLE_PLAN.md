# Ansible Deployment Plan

## Current state

- Ansible can connect to the EC2 instance.
- Host verification confirms Docker is running and enabled.
- Host verification confirms Docker Compose is installed.
- The application directory is created on EC2.
- The Compose file is copied to the application directory.

## Next step

Copy the non-secret Traefik configuration:

- Copy `config/traefik.yml` into the application directory.
- Set ownership to `ubuntu:ubuntu`.
- Set the file mode to `0644`.

## Later steps

1. Manage secrets separately.
2. Create `acme.json` with mode `0600`.
3. Start the Compose stack idempotently.
4. Verify container health.
