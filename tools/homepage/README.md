# Homepage

Homepage is an open‑source, highly‑customizable dashboard that aggregates over 100 service APIs.  
It runs in Docker and serves a static web UI on port `3000` inside the container.

<img src="https://assets.czaini.net/images/homepage-clip.jpg" height="75%" width="75%" />   

---

## Public Instance

See [Docker configuration](./public-instance/docker-compose.yml) here

* `7575` → Public dashboard URL (e.g. `http://localhost:7575`).  
* Configuration files live in `public-instance/config`.

## Administrator Instance

See [Docker configuration](./admin-instance/docker-compose.yml) here

* `3330` → Admin dashboard URL.  
* `dockerproxy` provides read‑only access to the Docker socket for service discovery.

## Volumes

* `./config:/app/config` – Holds all YAML config files (`services.yaml`, `settings.yaml`, etc.).

## Ports

* `7575` – Public dashboard.  
* `3330` – Admin dashboard.  

---  

For full configuration options, see the [official documentation](https://gethomepage.dev/).
