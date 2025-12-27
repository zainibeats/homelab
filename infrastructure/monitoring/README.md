# Monitoring Stack

This setup is based on the configuration provided by [brandonleegit/OpenSourceMonitoring](https://github.com/brandonleegit/OpenSourceMonitoring).

This directory contains a Docker Compose setup for a basic monitoring stack using:

-   **Prometheus**: Time-series database and monitoring system.
-   **Grafana**: Visualization and analytics platform.
-   **Node Exporter**: Exporter for hardware and OS metrics exposed by *NIX kernels.
-   **cAdvisor**: Analyzes resource usage and performance characteristics of running containers.

## Configuration

1.  **Host Directory Setup**: Create the necessary directory structure and placeholder files on your host machine using the following commands in your home directory (`~`). You can copy the entire block and paste it into your terminal:
    ```bash
    mkdir -p ~/promgrafnode/prometheus
    mkdir -p ~/promgrafnode/grafana/provisioning/datasources
    touch ~/promgrafnode/docker-compose.yml
    touch ~/promgrafnode/prometheus/prometheus.yml
    ```
2.  **Prometheus Configuration**: The Prometheus service mounts a configuration file from `~/promgrafnode/prometheus/prometheus.yml` on the host.
    *   A basic `prometheus.yml` is provided in *this* directory (`monitoring/prometheus.yml`). You need to **copy** the contents of this file (or the file itself) to `~/promgrafnode/prometheus/prometheus.yml` on your host machine, replacing the empty file created by the `touch` command above. Adjust the configuration if needed.
3.  **Grafana Configuration & Data**: Grafana mounts volumes for its data (`~/promgrafnode/grafana`) and provisioning (`~/promgrafnode/grafana/provisioning/datasources`). The necessary directories should have been created in step 1.
    *   You can place datasource configuration files (e.g., to automatically add the Prometheus datasource) in the `~/promgrafnode/grafana/provisioning/datasources` directory.
4.  **Permissions (PUID/PGID)**: The `prometheus` and `grafana` services are configured to run with user/group ID `1002`. Ensure the host directories (`~/promgrafnode/*`) have appropriate permissions for this user/group, or update the `user` directive in the `docker-compose.yml` to match a user/group that owns the directories.
5.  **Volumes**: Ensure the host paths used for volumes exist and have the correct permissions (as set up in previous steps):
    *   `~/promgrafnode/prometheus/prometheus.yml`
    *   `~/promgrafnode/prometheus`
    *   `~/promgrafnode/grafana/provisioning/datasources`
    *   `~/promgrafnode/grafana`

## Setup

1.  Ensure all configuration steps above (especially creating directories and copying the `prometheus.yml` file contents) are completed.
2. Run node-exporter container on machines to be monitored. 
```bash
# docker-compose.yml example
networks:
  monitoring:
    driver: bridge
volumes:
  prometheus_data: {}
services:
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: unless-stopped
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    ports:
      - 9100:9100
    networks:
      - monitoring
```

3.  Navigate to the `monitoring` directory:
    ```bash
    cd monitoring
    ```
4.  Start the services using Docker Compose:
    ```bash
    docker-compose up -d
    ```

## Accessing Services

-   **Prometheus**: `http://<your-server-ip>:9090`
-   **Grafana**: `http://<your-server-ip>:3000` (Default login: admin/admin)
-   **Node Exporter Metrics**: `http://<your-server-ip>:9100/metrics`
-   **cAdvisor**: `http://<your-server-ip>:8081`
