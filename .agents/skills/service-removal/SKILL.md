---
name: service-removal
description: Guides the agent through the complete decommissioning of a service or feature from the homelab environment. This includes identifying all references in configuration files (Docker Compose, environment variables, networking), purging them, and performing a final documentation audit to ensure no "ghost" references remain. Use this skill when a service is being retired or removed from the infrastructure.
---

# Service Removal

Guide the agent through the complete decommissioning of a service or feature from the homelab environment.

## Procedure

1. **Identify Scope**: Ask the user for the name of the service to be removed.
2. **Search**: Perform a project-wide search (excluding `.git`, `node_modules`, and `obsidian-vault/`) to find all references to the service.
   - Use `grep` or `rg` if available.
   - Look specifically for:
     - Docker Compose files (`docker-compose.yml`, `docker-compose.yaml`)
     - Environment variables (`.env`, `.env.example`)
     - Configuration files (`nginx/`, `traefik/`, `etc/`)
     - Documentation (READMEs, `private-homelab-docs/`)
3. **Report Findings**: Provide a list of all files and lines where the service was found.
4. **Execution Plan**: Propose a plan to remove or update each reference.
5. **Execute Edits**: Perform the changes in small, logical increments.
6. **Documentation Audit**: 
   - Explicitly check `private-homelab-docs/` for lingering metadata (links, IP addresses, descriptions).
   - Run the `docs-health-check` skill to verify the overall state of the documentation.
7. **Verification**: Confirm with the user that all references have been removed and the service is decommissioned.

## Notes
- Be extremely careful with `private-homelab-docs/` to ensure no "ghost" documentation remains.
- If the service is a primary component (e.g., a gateway or storage), warn the user about potential downstream impacts before proceeding.
