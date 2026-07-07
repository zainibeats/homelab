# Ansible Deployment Plan

## Current state

- Ansible can connect to the EC2 instance.
- Host verification confirms Docker is running and enabled.
- Host verification confirms Docker Compose is installed.
- The application directory is created on EC2.
- The Compose file is copied to the application directory.
- The Traefik configuration is copied to the application directory.
- The deployment copies a Vault-encrypted runtime environment file.

## Next step

Create Traefik's ACME certificate storage:

- Create the `letsencrypt` directory.
- Create an empty `acme.json` with mode `0600`.
- Ensure both are owned by `ubuntu:ubuntu`.

## Later steps

1. Start the Compose stack idempotently.
2. Verify container health.
