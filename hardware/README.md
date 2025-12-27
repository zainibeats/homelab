# Homelab Hardware

This section documents the physical hardware that powers my home lab. It covers current devices, network architecture, power‑management strategies, and future build plans.

---

## Current Hardware Overview
| Device | Role | CPU | GPU | RAM | Storage | Motherboard | NIC | Case |
|--------|------|-----|-----|-----|---------|-------------|-----|------|
| **Primary Desktop** | Workstation / gaming | Ryzen 9 9950X | RTX 5080 FE | 64 GB DDR5-6000 CL 30 | Samsung 990 Pro 2 TB (Linux), Samsung 9100 Pro 2 TB (Windows), WD Black SN850 2 TB NVMe, Samsung 870 Evo 4 TB HDD | MSI MPG X870E EDGE TI WIFI ATX AM5 | Onboard 5GbE & Dual SFP+ Mellanox ConnectX-4 | Corsair FRAME 4000D RS ARGB |
| **NAS** | Bulk storage & backups | Intel Xeon E3‑1235L V5 @ 2 GHz (4 c) | – | 32 GB DDR4‑2400 ECC | 2× Samsung 870 Evo 1 TB SSDs (mirrored boot), Samsung 980 Pro 1TB NVMe (L2ARC), 2× Seagate IronWolf Pro 8 TB HDDs | Supermicro MBD‑X11SSL‑F O mATX | Onboard 1GbE & Dual SFP+ Intel X570| Fractal Node 804 |
| **Rack‑mount Compute Node** | ProxmoxVE, gaming VMs, AI, transcoding | Ryzen 9 5900X | RTX 3070 Ti | 64 GB DDR4‑4000 (4×16) | 1 TB NVMe SSD | Asus ROG STRIX B550‑F GAMING WIFI ATX AM4 | Onboard 2.5GbE & Dual SFP+ Mellanox ConnectX-3 | Sliger CX4170a  (4U) |
| **Always‑On Utility Node** | Low‑power (eventually) server for services & WoL/IPMI | Intel Core i7‑7700 (6 c/12 t) | NVIDIA GTX 1050 2 GB | 16 GB DDR4 | 1 TB HDD | Proprietary HP board | – | HP Pavilion Gaming Desktop 790‑0050xt |
| **Miscellaneous** | Network services, monitoring & automation | Raspberry Pi 5 | – | 8 GB | – | – | – | – |

### Server Rack
- StarTech Open Frame 12U adjustable depth rack
   - **U1–U2**: Shelf which holds my NAS, Pi 5, QNAP switch, etc.
   - **U3**: TP‑Link TL‑SX3008F SFP+ Switch
   - **U4**: Pending decision
   - **U5–U6**: Utility node placeholders
   - **U7–U10**: Compute node
   - **U11–U12**: Cyberpower UPS 1500VA 

---

## Network Architecture

- **Core Switch:** TP‑Link TL‑SX3008F SFP+ (10 Gb island). All 10 Gb NICs (workstation, compute node, NAS, services) connect here for local traffic.
- **Access Layer:** QNAP QSW‑12104‑2S‑A‑US (2.5 Gb) connected to the core via a short passive DAC.
- **House Router:** AX1500 Wi‑Fi 6 router with 1 Gb wall port; uplink to the core switch.
- **Port Mapping on Core Switch**
  - Port 1: NAS → DAC
  - Port 2: Compute node → DAC
  - Port 3: Primary desktop → AOC
  - Port 7: QNAP access switch → DAC
  - Port 8: Router uplink → RJ45 SFP+ transceiver
- **Traffic Flow:** All local traffic (NAS ↔ workstation/compute) stays on the 10 Gb island; Internet traffic uses the 1 Gb uplink.

---

## Build Plans & Future Hardware

- **Primary Desktop**  
  - Goal: Complete – Upgrade over time  
  
- **Compute Node**  
  - Goal: Rack‑mounted GPU compute node powered on demand. Uses my retired RTX 3070 Ti desktop in a 4U chassis; CPU upgrade is optional.  

- **Always‑On Utility Node**  
  - Goal: Replace HP Pavilion with low‑power rackmount server (e.g., Intel i5‑13500 or similar) hosting services and providing WoL/IPMI wake‑up for the compute node.  

- **NAS**  
  - Goal: Continue using FractalNode 804 as dedicated storage; existing setup remains unchanged.  
  *Will be used as offsite backup at co-location when available.*
