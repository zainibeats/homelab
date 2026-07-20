# Homelab Hardware

This section documents the physical hardware that powers my home lab. It covers the current devices, their general roles, and future build plans.

> For my build processes, insights, stories, photos and more, visit my [blog](https://czaini.net/blog).

---

## Current Hardware Overview

### Primary Desktop

**Role**: Workstation / gaming  
- *CPU*: Ryzen 9 9950X  
- *GPU*: RTX 5080 FE  
- *RAM*: 32 GB DDR5‑6000 CL30  
- *Storage*:
  - Samsung 990 Pro 2 TB (Linux)  
  - Samsung 9100 Pro 2 TB (Windows)  
  - WD Black SN850 2 TB NVMe  
  - Samsung 870 Evo 4 TB SATA SSD  
- *Motherboard*: MSI MPG X870E EDGE TI WIFI ATX AM5  
- *NIC*: Onboard multi-gig Ethernet and dual SFP+
- *Case*: Corsair FRAME 4000D RS ARGB  

### NAS

**Role**: Bulk storage & backups  
- *CPU*: Intel Xeon E3‑1235L V5 @ 2 GHz (4 c)  
- *RAM*: 32 GB DDR4‑2400 ECC  
- *Storage*:
  - Mirrored SSD boot devices
  - NVMe cache device
  - Mirrored HDD pools for media, applications, backups, and lab storage
- *Motherboard*: Supermicro MBD‑X11SSL‑F O mATX  
- *NIC*: Onboard Ethernet and dual SFP+
- *Case*: Fractal Node 804  

### Rack‑mount Compute Node

**Role**: ProxmoxVE, gaming VMs, AI, transcoding  
- *CPU*: Ryzen 9 5900X  
- *GPU*: RTX 3070 Ti  
- *RAM*: 64 GB DDR4‑4000 (4×16)  
- *Storage*: 2 x 1 TB NVMe SSD  
- *Motherboard*: Asus ROG STRIX B550‑F GAMING WIFI ATX AM4  
- *NIC*: Onboard multi-gig Ethernet and dual SFP+
- *Case*: Sliger CX4170a (4U)  

### Utility Node

**Role**: Low‑power server for always-on services and management tasks
- *CPU*: Intel Core i7‑7700 (6 c/12 t)  
- *GPU*: NVIDIA GTX 1050 2 GB  
- *RAM*: 16 GB DDR4  
- *Storage*: 1 TB HDD  
- *Motherboard*: Proprietary HP board  
- *Case*: HP Pavilion Gaming Desktop 790‑0050xt  

### Miscellaneous

**Role**: Network services, monitoring & automation  
- Raspberry Pi 5 8 GB


## Server Rack

- StarTech Open Frame 12U adjustable depth rack
  - NAS and utility devices
  - Core and access switching
  - Rack-mount compute node
  - UPS for power protection

---

## Network Overview

The lab uses a small 10 Gb switching core for high-throughput local storage and compute traffic, with an access layer for lower-power devices and management connectivity. The network is segmented by device and workload type, with detailed implementation notes kept in private documentation.

---

## Build Plans & Future Hardware

- **Primary Desktop**  
  - Goal: Complete – Upgrade over time  
  
- **Compute Node**  
  - Goal: Rack‑mounted GPU compute node powered on demand. Uses my retired RTX 3070 Ti desktop in a 4U chassis; CPU upgrade is optional.  

- **Always‑On Utility Node**  
  - Goal: Replace HP Pavilion with low‑power rackmount server (e.g., Intel i5‑13500 or similar) for always-on services and management tasks.

- **NAS**  
  - Goal: Continue using FractalNode 804 as dedicated storage; existing setup remains unchanged.  
  - Long-term goal: expand backup strategy as the lab evolves.
