# Homelab

This repository contains configuration files and documentation for my homelab setup, including Docker Compose stacks, infrastructure automation, service documentation, and hardware that powers the environment. Further details about the hardware inventory are available in the [hardware readme](./hardware/README.md).

> For my build processes, insights, stories, photos, and more, visit my [blog](https://czaini.net/blog).

## Infrastructure Overview

### On-Prem

| Device                     | Purpose                                       | OS |
| -------------------------- | --------------------------------------------- | --- |
| **TrueNAS Server**         | Centralized storage and backups               | TrueNAS Scale |
| **Application Server**     | Primary application hosting                   | Ubuntu Server LTS |
| **Raspberry Pi**           | Network services, monitoring and automation   | Raspberry Pi OS Lite |
| **Rackmount Compute Node** | Virtual machines, remote desktop and testing  | Proxmox VE |

### Cloud Instances
| Provider                   | Purpose                                       | OS |
| -------------------------- | --------------------------------------------- | --- |
| Oracle                     | Game servers, Matrix, and NetBird server      | Ubuntu Server LTS |
| Azure                      | Jump server                                   | Debian |


## Project Organization

Services are organized into logical categories for easier management and navigation:
- **[Automation](./automation/README.md)** - Home automation, Ansible host management, and AI platforms
- **[Gaming](./gaming/README.md)** - Game server stacks and runtime documentation
- **[Infrastructure](./infrastructure/README.md)** - Networking, proxy, VPN, monitoring, dashboards, version control, container management, and Terraform-managed cloud infrastructure
- **[Media](./media/README.md)** - Media automation, management, and streaming services
- **[Storage](./storage/README.md)** - Data storage, backup, and security services
- **[Utilities](./utilities/README.md)** - General-purpose tools including file conversion, IT utilities, secret sharing, and virtual browser

## AI Agents
This repository includes an AI agent framework located in the `.agents` directory. 
- **[AGENTS.md](./AGENTS.md)** - Core rules, behaviors, and instructions for the AI agents.
- **[.agents](./.agents)** - Contains specialized skills and configurations used by the agents to perform tasks like documentation audits and conventional commit generation.

## Storage Overview

Storage is provided by a dedicated NAS (TrueNAS Server) and separated by category. Media, application data, backups, virtual machine storage, etc. are organized into separate datasets and shares.

## Automatic Updates

Utilizing **Watchtower** for automatic Docker container updates.

I've configured it to run daily at 5:00 AM to minimize disruption during peak usage hours. See the [Watchtower documentation](./infrastructure/watchtower/README.md) for configuration details and usage instructions.
