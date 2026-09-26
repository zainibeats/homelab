# Homelab

This repository contains configuration files and documentation for my homelab setup, including Docker Compose stacks, infrastructure automation, service documentation, and hardware that powers the environment. Further details about the hardware inventory are available in the [Hardware](./hardware/README.md) readme.

> For my build processes, insights, stories, photos, and more, visit my [blog](https://czaini.net/blog).

## Infrastructure Overview
| Device                     | Purpose                                       | OS |
| -------------------------- | --------------------------------------------- | --- |
| **TrueNAS Server**         | Centralized storage and backups               | TrueNAS Scale |
| **Ubuntu Server**          | Primary application hosting                   | Ubuntu Server 22.04 LTS |
| **Raspberry Pi**           | Network services, monitoring and automation   | Raspberry Pi OS Lite |
| **Rackmount Compute Node** | Virtual machines, remote desktop and testing  | Proxmox VE |

## AI Agents
This repository includes an AI agent framework located in the `.agents` directory. 
- **[AGENTS.md](./AGENTS.md)** - Core rules, behaviors, and instructions for the AI agents.
- **[.agents](./.agents)** - Contains specialized skills and configurations used by the agents to perform tasks like documentation audits and conventional commit generation.

## Storage Overview

Storage is provided by a dedicated NAS and separated by workload type. Media, application data, backups, virtual machine storage, photos, and private files are organized into separate datasets and shares so services can be managed and backed up independently.

## Automatic Updates

Utilizing **Watchtower** for automatic Docker container updates.

I've configured it to run daily at 5:00 AM to minimize disruption during peak usage hours. See the [Watchtower documentation](./infrastructure/watchtower/README.md) for configuration details and usage instructions.
