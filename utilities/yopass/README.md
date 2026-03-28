# Yopass

Yopass is a lightweight, self‑hosted service for securely sharing secrets, passwords, and files. It encrypts data client‑side, stores it temporarily in Memcached, and returns a one‑time URL that expires automatically.

The web UI is available on port **8889** (mapped from the container's port 80). 

## Configuration

* **Memcached** – Used for temporary storage of encrypted payloads. Exposed on port `11211` within the Compose network.
* **Yopass** – Runs on port `80` internally; the compose file maps it to `8889` on the host.

The service is started with the following command line arguments:

```text
--memcached=memcached:11211 --port 80
```

No additional environment variables are required for the default setup.

## Persistence

This configuration is meant for quick, temporary sharing. If you need persistent storage or advanced security options, refer to the original project documentation on GitHub and adjust the Compose file accordingly.

---

*Source: <https://github.com/jhaals/yopass> – self‑hosted secret sharing.*
