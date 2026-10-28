# Ollama + Open WebUI

Run large language models locally with Ollama and use them through Open WebUI. The two services are separate stacks (`ollama/` and `open-webui/`), so either side can be swapped (e.g. LM Studio, a custom Ollama setup, or an API-key service) without changing the other.

**Runs on:** a host with an NVIDIA GPU (GPU Compute Node, Desktop)

## Prerequisites

- An NVIDIA GPU with the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) (recommended). Without one, remove the `deploy` section from `ollama/docker-compose.yml`.
- Two external Docker networks for Open WebUI:
  - `traefik-proxy` - Carries the `open-webui.${DOMAIN}` routes. The [Traefik](../../networking/traefik/README.md) stack creates it. On a host without Traefik, create it by hand (`docker network create traefik-proxy`) or remove it from `open-webui/docker-compose.yml`.
  - `tmdb-net` - Lets Open WebUI talk to my [TMDB MCP server](https://github.com/zainibeats/tmdb-mcp) and to [SearXNG](../../utilities/searxng/README.md) when they run on the same host. Create it with `docker network create tmdb-net`, or remove it from `open-webui/docker-compose.yml` if you don't use either. Docker networks are per host, so this only connects containers on the same machine.

## Setup

1. Ollama:
   ```bash
   cd ollama
   cp .env.example .env   # set MODELS_DIR; keep OLLAMA_HOST=0.0.0.0:11434
   docker compose up -d
   ```
   Ollama uses host networking. Open WebUI reaches it through `host.docker.internal`, which arrives on the Docker bridge, so Ollama must listen on all interfaces: `OLLAMA_HOST=0.0.0.0:11434` in `ollama/.env` (without it the compose file defaults to `127.0.0.1:11434`). This also exposes Ollama on the LAN, so restrict port `11434` with the host firewall.
2. Open WebUI:
   ```bash
   cd open-webui
   cp .env.example .env   # set WEBUI_SECRET_KEY and the rest
   docker compose up -d
   ```

### Custom models

Mount a directory of model files with `MODELS_DIR`, then create a model from a Modelfile (see `ollama/models/Modelfile.example`):

```bash
docker exec -it ollama sh
ollama create custom-model-name -f /models/path/to/Modelfile
```

The models directory is mounted at `/models`, so use the path _inside_ the container (e.g. `/models/gpt-oss/Modelfile`).

## Configuration

Ollama (`ollama/.env`):

- `MODELS_DIR` - Host directory with model files, mounted at `/models`.
- `OLLAMA_HOST` - Listen address. `0.0.0.0:11434` so Open WebUI can reach Ollama; the compose default is `127.0.0.1:11434`.

Open WebUI (`open-webui/.env`):

- `DOMAIN` - Base domain for the Traefik routes (`open-webui.${DOMAIN}`).
- `SUBDOMAIN` - LAN subdomain for the second route (`open-webui.${SUBDOMAIN}.${DOMAIN}`).
- `OLLAMA_BASE_URL` - Ollama URL: `http://host.docker.internal:11434`. The compose file maps `host.docker.internal` to the host (`extra_hosts: host-gateway`). If Ollama ever runs on a shared Docker network instead of host networking, use `http://ollama:11434`.
- `WEBUI_SECRET_KEY` - Secret used to secure sessions. Set a long random value.
- `CORS_ALLOW_ORIGIN` - Origins allowed by CORS (the LAN URL and the Traefik hostname).
- `ENABLE_WEB_SEARCH` - `True` (the default when unset) enables web search; `False` turns it off.
- `WEB_SEARCH_ENGINE` - Search engine (`searxng`, `bing`, `duckduckgo`, ...).
- `SEARXNG_QUERY_URL` - SearXNG query URL. When SearXNG runs on the same host (both on `tmdb-net`), use the container name and port: `http://searxng-core:8080/search?q=<query>`. If SearXNG runs on a different host, use its Traefik URL instead: `https://search.${DOMAIN}/search?q=<query>`.
- `WEB_SEARCH_RESULT_COUNT` - Number of search results to use.

## Routing & Ports

- `open-webui.${DOMAIN}` and `open-webui.${SUBDOMAIN}.${DOMAIN}` - Open WebUI through Traefik.
- `8808` → `8080` - Open WebUI on the host.
- `11434` - Ollama API on the host (host networking).
- Networks: Open WebUI joins the external `traefik-proxy` and `tmdb-net`; Ollama uses `network_mode: host`.

## Data & Backups

- `ollama` volume → `/root/.ollama` - Downloaded models; re-downloadable.
- `${MODELS_DIR}` → `/models` - Custom model files and Modelfiles.
- `open-webui` volume → `/app/backend/data` - Users, chats, and settings. Back this up.

## Troubleshooting

- Open WebUI shows no models: Ollama isn't reachable at `host.docker.internal:11434`. Confirm `OLLAMA_HOST=0.0.0.0:11434` is set in `ollama/.env` and test with `docker exec open-webui curl -s http://host.docker.internal:11434/api/tags`.
- `docker compose up` fails with "network tmdb-net declared as external, but could not be found": create it or remove it from the compose file.

AI agent context bundles and skills that used to live here are in [`agent-context/`](../../agent-context/README.md).
