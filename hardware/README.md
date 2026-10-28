# Homelab Hardware

The machines running in the lab. Each one's purpose is listed in the [top-level README](../README.md#on-prem).

> Build logs, photos and part-level details are on my [blog](https://czaini.net/blog).

| Machine            | CPU            | GPU         | RAM       | Storage              |
| ------------------ | -------------- | ----------- | --------- | -------------------- |
| NAS                | Xeon E3-1235L  | —           | 32 GB ECC | Mirrored HDD pools   |
| Application Server | Core i7-7700   | GTX 1050    | 16 GB     | 1 TB HDD             |
| Raspberry Pi 5     | —              | —           | 8 GB      | —                    |
| GPU Compute Node   | Ryzen 9 5900X  | RTX 3070 Ti | 64 GB     | 2 × 1 TB NVMe        |
| Workstation        | Ryzen 9 9950X  | RTX 5080    | 32 GB     | ~10 TB across 4 SSDs |

## Rack & Network

A 12U open-frame rack holds the NAS, the GPU Compute Node, the switches and a UPS. A small 10 Gb core carries storage and compute traffic, with an access layer for lower-power devices. The network uses VLANs to separate lab, infrastructure, IoT, user and guest traffic.

## Plans

- Replace the Application Server with a low-power rackmount box.
