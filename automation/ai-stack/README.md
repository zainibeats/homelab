# Ollama + Open WebUI

This setup allows you to run large language models (LLMs) locally using Ollama and interact with them through a user-friendly web interface provided by Open WebUI.

## Services

- **Ollama**: Serves and manages LLMs locally.
- **Open WebUI**: A web interface for interacting with Ollama-served models.

## Configuration

1. **GPU Acceleration (Optional but Recommended)**
   The `ollama` service is configured to use NVIDIA GPUs (`deploy.resources.reservations.devices`). Ensure you have the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) installed on your host if you want to use GPU acceleration. If you don’t have an NVIDIA GPU or don’t want to use it, remove or comment out the `deploy` section in `ollama/docker-compose.yml`.

2. **Port Mapping**
   Open WebUI is exposed as port `3000` on the host by default (container port `8080`). You can change the host port if needed.

3. **Environment Variables**
   - The **ollama** and **open-webui** directories are now separate, enabling you to swap providers (e.g., LM Studio, custom Ollama setups, or API-key services) without altering the overall architecture.

   - The external Docker network `tmdb-net` exists specifically so that this stack can communicate with my custom [TMDB MCP server](https://github.com/zainibeats/tmdb-mcp). If you're not using the MCP tool, the network isn't required.
   - **Ollama (`ollama/.env.example`)**
     - `MODELS_DIR`: Directory containing model files that should be mounted into the container.
   - **Open WebUI (`open-webui/.env.example`)**
     - `OLLAMA_BASE_URL`: Base URL for Ollama (default: `http://ollama:11434`).
     - `WEBUI_SECRET_KEY`: Secret key used by Open WebUI to secure cookies.
     - `CORS_ALLOW_ORIGIN`: Origins allowed by CORS.
     - `ENABLE_WEB_SEARCH`: Set to `True` to enable the built-in web search feature.
     - `WEB_SEARCH_ENGINE`: Search engine to use (e.g., `bing`, `duckduckgo`).
     - `SEARXNG_QUERY_URL`: URL of a Searxng instance for query expansion.
     - `WEB_SEARCH_RESULT_COUNT`: Number of search results returned by the UI.

4. **Models Directory (Optional)**
   To use custom models, mount a local directory containing your models into the Ollama container using the `MODELS_DIR` variable.

5. **WebUI Secret Key (Optional)**
   For production environments, set the `WEBUI_SECRET_KEY` to a secure, random string.

## Custom Models

To use custom models from your local directory, create them using a Modelfile:

```bash
docker exec -it ollama sh
ollama create custom-model-name -f /models/path/to/Modelfile
```

> **Note**: Since the docker volume mounts the models directory to `/models` inside the container, the path in the command should be the absolute path _inside_ the container (e.g., `/models/gpt-oss/Modelfile`).
