# Homelab Hardware

This section documents the physical hardware that powers my home lab. It covers current devices, network architecture, power‑management strategies, and future build plans. 

> For my build processes, insights, stories, photos and more, visit my [blog](https://blog.czaini.net).

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
- *NIC*: Onboard 5GbE & Dual SFP+ Mellanox ConnectX‑4  
- *Case*: Corsair FRAME 4000D RS ARGB  

### NAS

**Role**: Bulk storage & backups  
- *CPU*: Intel Xeon E3‑1235L V5 @ 2 GHz (4 c)  
- *RAM*: 32 GB DDR4‑2400 ECC  
- *Storage*:
  - 2× Samsung 870 Evo 1 TB SSDs (mirrored boot)  
  - Samsung 980 Pro 1TB NVMe (L2ARC)  
  - 2× Mirrored Seagate IronWolf Pro 8 TB HDDs (Jellyfin media storage)
  - 2x Mirrored Seagate Exos 20 TB HDDs (Immich, Nextcloud, Proxmox, etc.)
- *Motherboard*: Supermicro MBD‑X11SSL‑F O mATX  
- *NIC*: Onboard 1GbE & Dual SFP+ Intel X570  
- *IPMI*: Supermicro onboard NIC connects to the QNAP access switch on VLAN 20 (Infra) for remote management. See [Network Architecture](##network-architecture) below for details
- *Case*: Fractal Node 804  

### Rack‑mount Compute Node

**Role**: ProxmoxVE, gaming VMs, AI, transcoding  
- *CPU*: Ryzen 9 5900X  
- *GPU*: RTX 3070 Ti  
- *RAM*: 64 GB DDR4‑4000 (4×16)  
- *Storage*: 2 x 1 TB NVMe SSD  
- *Motherboard*: Asus ROG STRIX B550‑F GAMING WIFI ATX AM4  
- *NIC*: Onboard 2.5GbE & Dual SFP+ Mellanox ConnectX‑3  
- *Case*: Sliger CX4170a (4U)  

### Utility Node

**Role**: Low‑power server for services & WoL/IPMI  
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
  - **U1–U2**: Shelf which holds my NAS, Pi 5, QNAP switch, etc.
  - **U3**: TP‑Link TL‑SX3008F SFP+ Switch
  - **U4**: Pending decision
  - **U5–U6**: Utility node placeholders
  - **U7–U10**: Compute node
  - **U11–U12**: Cyberpower UPS 1500VA  

---

## Operating / Wake‑on‑LAN Configuration

### Raspberry Pi 5 

Central SSH host that broadcasts magic packets from any machine on the network.  
    
1. Run wakeonlan command directly:
    ```bash
    wakeonlan 00:11:22:33:44:55
    ```
    
2. Alternatively, use short script:
    ```bash
    ## ~/wol/utility-wake.sh
    #!/bin/bash
  
    ## MAC address of the target machine
    TARGET_MAC="00:11:22:33:44:55"
     
    wakeonlan "$TARGET_MAC"
    ```
    Make it executable: `chmod +x ~/wol/utility-wake.sh`
  

### Rack‑mount Compute Node

- Powered on via Wake‑on‑LAN.  
- Currently powered off manually via ssh or Proxmox web ui

### Utility Node

- Powered on via Wake‑on‑LAN
- Systemd service `wakeonlan.service` configures the NIC with `ethtool`

1. Example unit file (enabling WoL on interface `enp3s0`):
    ```yaml
    ## /etc/systemd/system/wakeonlan.service
    [Unit]
    Description=Enable Wake On Lan
    After=network.target
        
    [Service]
    Type=oneshot
    ExecStart=/usr/sbin/ethtool -s enp3s0 wol g
    RemainAfterExit=yes
        
    [Install]
    WantedBy=multi-user.target
    ```
      
2. Enable the systemd service
    ```bash
    sudo systemctl enable --now wakeonlan.service
    ```

---

## Network Architecture

- **Core Switch:** TP‑Link TL‑SX3008F SFP+ (10 Gb island). All 10 Gb NICs (workstation, compute node, NAS, services) connect here for local traffic.
- **Access Layer:** QNAP QSW‑12104‑2S‑A‑US (2.5 Gb) connected to the core via a short passive DAC.
- **House Router:** UniFi Dream Router 7
### VLANs
| ID | Name    |
|----|---------|
| 1  | Internal |
| 10 | Homelab |
| 20 | Infra   |
| 60 | Zigbee  |
| 70 | IoT     |
| 80 | Guest   |
| 999 | Dummy   |


### Port Mapping (Core Switch)
| Port | Device / Link | VLAN | PVID |
|------|--------------|------|------|
| 1    | NAS → DAC    | 10   | 10   |
| 2    | Compute → DAC| 10   | 10   |
| 3    | Desktop → AOC| 10   | 10   |
| 7    | Access → DAC | 20   | 20   |
| 8    | Router uplink| 10/20| 999 (unused dummy VLAN) |

*Port 8 is a trunk carrying Homelab (10) and Infra (20).  
The 999 VLAN is a placeholder as SX3008F Web UI requires a PVID value for each port.*

- **Traffic Flow:** All local traffic (NAS ↔ workstation/compute) stays on the 10 Gb island; Internet and Inter-VLAN traffic uses the router’s 2.5 Gb uplink.


![Network Topology Diagram](https://assets.czaini.net/images/homelab_diagram.jpg)

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
